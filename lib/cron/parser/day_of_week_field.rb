class Cron::Parser
  class DayOfWeekField < Field
    def self.allowed_values
      ("0".."7").to_a + ("00".."07").to_a + %w{ sun mon tue wed thu fri
                                                sat }.map(&:upcase)
    end

    def self.upper_bound;                "0"                       end
    def self.lower_bound;                "7"                       end
    def self.allowed_special_characters; %w{ * / , - }             end
    def self.specifications
      extra_specs = [
        {
         rule: /\A(?<day>(sun|mon|tue|wed|thu|fri|sat))\Z/i,
         yields: ->(day, options) do
           return [day] if options[:exclude_preposition]
           return self.generate_meaning([day], options[:unit])
         end,
         for_fields: %w{ day_of_week }
        },
      ]
      super + extra_specs
    end

    def self.generate_meaning(list, unit)
      meaning = ""
      meaning += self.field_preposition(unit)
      meaning += " "
      meaning += list.map{ |d| self.ascii_weekday(d) }.uniq.join(", ")
      meaning
    end

    def self.ascii_weekday(day)
      case day.to_s.downcase
      when "0", "00", "7", "07", "sun"; "Sunday"
      when "1", "01", "mon";            "Monday"
      when "2", "02", "tue";            "Tuesday"
      when "3", "03", "wed";            "Wednsday"
      when "4", "04", "thu";            "Thursday"
      when "5", "05", "fri";            "Friday"
      when "6", "06", "sat";            "Saturday"
      end
    end
  end
end
