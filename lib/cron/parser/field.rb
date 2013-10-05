class Cron::Parser
  class Field
    attr_reader :pattern,
                :meaning

    def initialize(pattern)
      raise NotImplementedError.new("you just can't do that, sorry!
                    ".squish) if self.class == Cron::Parser::Field
      @pattern = pattern   # for current field only
      @meaning = validate! # current field
    end

    def inspect
      %Q{
          #<#{self.class.name}:#{Object::o_hexy_id(self)}>
          {
           :pattern => "#@pattern",
           :meaning => "#@meaning"
          }
      }.squish
    end

    def validate!
      investigate_invalid_values! # holmes, did you listen?
      match_data, meaning = nil
      self.class.specifications.each do |spec|
        next if (match_data = spec[:rule].match(@pattern)).nil?
        next unless spec[:for_fields].include? self.field_name
        meaning = spec[:meaning].(*match_data.captures, self.field_name)
        break if(match_data)
      end
      if match_data.nil? or meaning.nil?
        raise invalid_field_error_class.new("\"#{self.field_name}\" field's
                                           pattern is invalid".squish)
      end
      meaning
    end

    # and the magic lies here, in specs, yehh!
    def self.specifications
      [
       {
          rule: /\A
                \*
                \Z/x,
          meaning: ->(unit) { "every #{unit}" },
          for_fields: %w{ minute hour day_of_month month day_of_week }
        },
        {
          rule: //,
          meaning:->{},
          for_fields: %w{  }
        }
      ]
    end

    def investigate_invalid_values!
      invalids = []
      @pattern.split(/,|\/|\-/).uniq.map do |value|
        invalids << value unless self.class.allowed_values.to_a.include?(value)
      end
      invalids.delete("*")
      raise self.invalid_field_error_class.new("value: '#{invalids.join(', ')}'
      not allowed for '#{field_name}' field, run: '#{self.class}.allowed_values'
                                to know valid values".squish) if invalids.any?
    end

    # current field's name, for e.g. 'minute', 'hour', and likewise
    def field_name
      self.class.name.split("::").last.downcase \
        .sub("field", "").humanize.downcase
    end

    def self.field_name; self.new.field_name end

    # it's simple
    def invalid_field_error_class
      ("Invalid" + self.field_name.capitalize + "FieldError").
        classify.
        safe_constantize
    end
  end
end
