class Cron::Parser
  class Field
    attr_reader :pattern,
                :meaning,
                :warning

    def initialize(pattern)
      raise NotImplementedError.new("you just can't do that, sorry!
                    ".squish) if self.class == Cron::Parser::Field
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

    def validate!
      investigate_invalid_values! # holmes, did you listen that?

      meaning    = ""
      halt_loop  = false
      match_data = nil
      list       = []
      values     = @pattern.split(",")
      options    = { unit: self.field_name,
                     exclude_preposition: true
                   }

      values.map.with_index do |value, index|
        self.class.specifications.map do |spec|
          next unless spec[:for_fields].include? self.field_name
          next if (match_data = spec[:rule].match(value)).nil?
          if spec[:can_dominate_all]
            meaning = spec[:yields].(*match_data.captures, options)
            halt_loop = true and break
          end
          list << spec[:yields].(*match_data.captures, options)
          if spec[:can_halt]
            halt_loop = true
            @warning = "'#{value}' is valid but confusing pattern"
            break
          end
          break if match_data
        end
        break if halt_loop
      end

      list    = list.flatten.uniq.map(&:to_s).sort
      if meaning.==("") and list.empty?
        raise invalid_field_error_class.new("\"#{self.field_name}\" field's
                                                pattern is invalid".squish)
      end
      meaning = self.class.generate_meaning(list, field_name) if meaning.==("")
      meaning
    end

    # and the magic lies here, in specs, yehh!
    def self.specifications
      [
       {
         rule: /\A\*\Z/,
         yields: ->(options) do
           "every " + options[:unit].split("_").join(" ")
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week },
         can_dominate_all: true
       },
       {
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
         rule: /\A(?<value>\d+)\Z/,
         yields: ->(value, options) do
           return [value] if options[:exclude_preposition]
           return self.generate_meaning([value], options[:unit])
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week }
       },
       {
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
         rule: /\A(?<from>\d+)\-(?<to>\d+)\/(?<step>\d+)\Z/,
         yields: ->(from, to, step, options) do
           range = self.range_step_values(from.to_i, to.to_i, step.to_i)
           return range if options[:exclude_preposition]
           return self.generate_meaning(range, options[:unit])
         end,
         for_fields: %w{ minute hour day_of_month month day_of_week }
       },
       {
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

    def investigate_invalid_values!
      invalids = @pattern.split(/,|\/|\-/).uniq.collect do |value|
        value unless self.class.allowed_values.to_a.include?(value.upcase)
      end.compact
      invalids.delete("*")
      raise self.invalid_field_error_class.new("value: '#{invalids.join(', ')}'
      not allowed for '#{field_name}' field, run: '#{self.class}.allowed_values'
                                to know valid values".squish) if invalids.any?
    end

    # current field's name, for e.g. 'minute', 'hour', and likewise
    def field_name
      self.class.name.split("::").last.downcase.sub("of", "_of_").          \
                                sub("field", "").downcase
    end

    def self.field_name; self.new.field_name end

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

    # it's simple
    def invalid_field_error_class
      ("Invalid" + self.field_name.split("_").map(&:capitalize).join +      \
                               "FieldError").classify.safe_constantize
    end
  end
end
