class Cron
  class Parser
    attr_reader :pattern,
                :fields,
                :meaning, # umm, let me think about it
                :warnings

    FIELDS = %w{ minute hour day_of_month month day_of_week }

    def initialize(pattern = nil)
      @pattern = pattern
      @fields  = {}; FIELDS.map { |field| @fields[field.to_sym] = nil }
      validate! # and don't ask to dissect it!
      @meaning = humanize # being human, wtf!
    end

    # Inspects the parsed pattern, displays fields in pattern and warnings.
    def inspect
      %Q{
          #<#{self.class.name}:#{Object::o_hexy_id(self)}>
          {
            :pattern => "#@pattern",
            #{":warnings => \"" + self.warnings + "\"," if self.warnings }
            :fields  => #{@fields.inspect}
          }
      }.squish
    end

    # Alias of `meaning` getter method.
    # Returns human readable meaning for cron pattern after parsing it.
    def humanize
      @fields.collect do |_, field|
        field.meaning
      end.join("; ").chomp("; ")
    end

    # Returns warnings in pattern fields if any, occured while parsing those
    # fields.
    def warnings
      warnings = @fields.collect do |_, field|
        "for '#{field.field_name}' field: #{field.warning}" if field.warning
      end.compact.join(", ").chomp(", ")
      warnings == "" ? nil : warnings
    end

    # Alias of `new` method.
    def self.parse(pattern = nil) # oh, that sounds ridiculous!
      self.new(pattern).humanize
    end

    private

    # Internal method to validate the cron pattern. Raises errors if pattern is invalid.
    def validate!
      raise InvalidCronPatternError.new("cron pattern must be a string, please
                  read documentation".squish) unless @pattern.kind_of? String
      fix_common_typos! # how nasty!
      # do you know that cron has some pretty good fields, huh?
      # go and,
      validate_fields!
    end

    # Internal method to validate each field in the pattern.
    def validate_fields!
      pattern_fields = @pattern.split
      if pattern_fields.size != FIELDS.size
        raise InvalidCronPatternError.new("cron pattern must contain exact
                        #{FIELDS.size} fields seperated by whitespaces".squish)
      end
      FIELDS.map.with_index do |field, index|
        field_class           = self.class.name + "::" + field.split("_"). \
                                map(&:capitalize).join + "Field".squish.   \
                                classify
        @fields[field.to_sym] = field_class.safe_constantize.              \
                                new(pattern_fields[index])
      end
    end

    # Internal method to clean up the frequently made typos and mistakes in
    # the cron pattern.
    def fix_common_typos!
      # well, I don't know what kind of typos people do!
      @pattern.squish!
    end
  end
end
