class Cron
  class Parser
    attr_reader :pattern, :fields, :meaning

    def initialize(pattern = nil)
      @pattern = pattern
      @fields  = {
                  minute: nil, hour:         nil, day_of_month: nil,
                  month:  nil, day_of_week:  nil
                }
      validate!
      @meaning = self.humanize
    end

    def inspect
      %Q{
          #<#{self.class.name}:#{self.object_id}>
          {
            :pattern => "#@pattern",
            :fields  => #{@fields.inspect}
          }
      }.squish
    end

    def humanize
      @fields.collect do |_, field|
        next if field.nil?
        field.meaning.to_s
      end.
        join(", ").
        gsub(/(,\s){2,}/, ", ").
        chomp(", ")
    end

    def self.parse(pattern = nil)
      self.new(pattern, *args).humanize
    end

    #### Private #####

    private

    def validate!
      raise InvalidPatternError.new("pattern must be string") unless @pattern.kind_of? String
      fix_common_typos!
      validate_fields!
    end

    def validate_fields!
      fields = @pattern.split
      raise InvalidPatternError.new("pattern must contain exact five fields") if fields.size != 5
      minute_field, hour_field, day_of_month_field, month_field, day_of_week_field = *fields
      @fields[:minute]         = Cron::Parser::MinuteField.new minute_field
      # TODO
      # @fields[:hour]         = Cron::Parser::HourField.new hour_field
      # @fields[:day_of_month] = Cron::Parser::DayOfMonthField.new day_of_month_field
      # @fields[:month]        = Cron::Parser::MonthField.new month_field
      # @fields[:day_of_week]  = Cron::Parser::DayOfWeekField.new day_of_week_field
    end

    def fix_common_typos!
      # well, I don't know what kind of typos people do!
      @pattern.squish!
    end
  end
end