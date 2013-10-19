class Cron::Parser
  class Field
    attr_reader :pattern,
                :meaning,
                :warning

    def initialize(pattern)
      raise NotImplementedError.new("'Cron::Parser::Field' can't be initialized
                         directly".squish) if self.class == Cron::Parser::Field
      @pattern = pattern   # for current field only
      @warning = nil
      @meaning = validate! # current field
    end

    def inspect
      %Q{
          #<#{self.class.name}:#{Object::o_hexy_id(self)}>
          {
           :pattern => "#@pattern",
           #{":warning => #@warning," if @warning}
           :meaning => "#@meaning"
          }
      }.squish
    end

    # Recognizes and validates the current field in cron pattern.
    # FYI, all magic happens over here!
    def validate!
      investigate_invalid_values!

      meaning    = ""
      halt_loop  = false
      match_data = nil
      list       = []
      values     = @pattern.split(",")
      options    = {
                     unit: self.field_name,
                     exclude_preposition: true
                   }

      # iterate over all comma seperated values for current field
      values.map.with_index do |value, index|
        # look whether the value matches any of regex rule
        self.class.specifications.map do |spec|
          next unless spec[:for_fields].include? self.field_name
          next if (match_data = spec[:rule].match(value)).nil?

          # some special kind of values can dominate all other values for
          # current field, e.g. value such as '*'
          if spec[:can_dominate_all]
            meaning   = spec[:yields].(*match_data.captures, options)
            halt_loop = true and break
          end

          list << spec[:yields].(*match_data.captures, options)

          # some values are confusing or ambiguous, e.g. '8/2' -- but crontab
          # allows such values, but they can halt next comma seperated values
          # from being parsed for the current field of cron pattern
          if spec[:can_halt]
            @warning  = "'#{value}' is valid but confusing pattern"
            halt_loop = true
            break
          end
          # stop looking for other regex rules if values is matched here
          break if match_data
        end
        # stop iterating over comma seperated values if special-purpose flag:
        # `halt_loop` is set to `true` somewhere
        break if halt_loop
      end

      list = list.flatten.uniq.map(&:to_s).sort
      list = list.map(&:to_i).sort if !!(/minute|hour|day_of_month/ =~ field_name)
      if meaning.==("") and list.empty?
        raise invalid_field_error_class.new("\"#{self.field_name}\" field's
                                                pattern is invalid".squish)
      end
      meaning = self.class.generate_meaning(list, field_name) if meaning.==("")
      meaning
    end

    # List of regular expressions to match the different kind of values in cron
    # pattern fields, also produces partial meaning for the matched values
    def self.specifications
      [
       {
         # e.g.: "*"
         rule: /\A\*\Z/,
         yields: ->(options) do
           "every " + options[:unit].split("_").join(" ")
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week },
         can_dominate_all: true
       },
       {
         # e.g.: "*/2"
         rule: /\A\*\/(?<step>\d+)\Z/,
         yields: ->(step, options) do
           range = []
           (self.lower_bound.to_i..self.upper_bound.to_i).map do |value|
             range << value if value.modulo(step.to_i).zero?
           end
           list = range.any? ? range : [step]
           return list if options[:exclude_preposition]
           return self.generate_meaning(list, options[:unit])
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week }
       },
       {
         # e.g.: "4"
         rule: /\A(?<value>\d+)\Z/,
         yields: ->(value, options) do
           return [value] if options[:exclude_preposition]
           return self.generate_meaning([value], options[:unit])
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week }
       },
       {
         # e.g.: "3-26"
         rule: /\A(?<from>\d+)\-(?<to>\d+)\Z/,
         yields: ->(from, to, options) do
           range = (from..to).to_a
           list  = range.any? ? range : [from]
           return list.map(&:to_i) if options[:exclude_preposition]
           return self.generate_meaning(list, options[:unit])
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week }
       },
       {
         # e.g.: "3-26/2"
         rule: /\A(?<from>\d+)\-(?<to>\d+)\/(?<step>\d+)\Z/,
         yields: ->(from, to, step, options) do
           range = self.range_step_values(from.to_i, to.to_i, step.to_i)
           return range if options[:exclude_preposition]
           return self.generate_meaning(range, options[:unit])
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week }
       },
       {
         # e.g.: "12/3"
         rule: /\A(?<value>\d+)\/\d+\Z/,
         yields: ->(value, options) do
           return [value] if options[:exclude_preposition]
           return self.generate_meaning([value], options[:unit])
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week },
         can_halt: true
       }
      ]
    end

    # Checks for invalid characters and values for the current field.
    def investigate_invalid_values!
      invalids = @pattern.split(/,|\/|\-/).uniq.collect do |value|
        value unless self.class.allowed_values.to_a.include?(value.upcase)
      end.compact
      invalids.delete("*")

      err = nil
      if invalids.include?('') || invalids.include?(' ')
        err = "#{field_name} field's pattern is invalid, please run:
            '#{self.class}.allowed_values' to know valid values".squish
      elsif invalids.any?
        err = "value: '#{invalids.join(', ')}' not allowed for '#{field_name}'
        field, run: '#{self.class}.allowed_values' to know valid values".squish
      end
      raise self.invalid_field_error_class.new(err) if err
    end

    # Returns current field's name, for e.g. 'minute', 'hour', and likewise.
    def field_name
      self.class.name.split("::").last.downcase.sub("of", "_of_").          \
                                sub("field", "").downcase
    end

    def self.field_name; self.new.field_name end

    # Returns preposition for the current field to be prepended while generating
    # meaning (partial sentence).
    def self.field_preposition(field)
      case field
      when "minute"
        "at"
      when "hour", "day_of_month", "day_of_week"
        "on"
      when "month"
        "in"
      else
        "at"
      end
    end

    # An algorithm calculates and returns values exist for the expression
    # <from>-<to>/<step>.
    def self.range_step_values(from, to, step)
      values = [from]
      (from..to).map do |value|
        value += step
        if (value == values.last + step) and value <= to
          values.push value
        end
      end
      values
    end

    # Generates error class for the current cron field.
    def invalid_field_error_class
      ("Invalid" + self.field_name.split("_").map(&:capitalize).join +      \
                               "FieldError").classify.safe_constantize
    end
  end
end
