class Cron::Parser
  class Field
   attr_reader :pattern, :meaning

    def initialize(pattern)
      raise NotImplementedError.new("\"Cron::Parser::Field\" ain't accessible
                       directly".squish) if self.class == Cron::Parser::Field
      @pattern = pattern
      @meaning = validate!
    end

    def inspect
      %Q{
          #<#{self.class.name}:#{self.object_id}>
          {
           :pattern => "#@pattern",
           :meaning => "#@meaning"
          }
      }.squish
    end

    def validate!
      match_data, meaning = nil
      self.class.specifications.each do |spec|
        next if (match_data = spec[:rule].match(@pattern)).nil?
        meaning = spec[:meaning].(*match_data.captures)
        break if(match_data)
      end
      raise InvalidPatternError.new("\"#{self.field_name}\" field's
                     pattern is invalid".squish) if match_data.nil?
      meaning
    end

    def field_name
      self.class.name.split("::").last.downcase \
        .sub("field", "").humanize
    end

    def self.field_name
      self.new.field_name
    end
  end
end
