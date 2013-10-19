class Cron::Parser
  class HourField < Field
    def self.allowed_values; ("0".."9").to_a + ("00".."23").to_a   end
    def self.upper_bound;                self.allowed_values.last  end
    def self.lower_bound;                self.allowed_values.first end
    def self.allowed_special_characters; %w{ * / , - }             end
    def self.specifications
      super
    end

    # Converts 24-hour value to 12-hour am/pm value.
    def self.to_12h(hour)
      case hour.to_i
      when 0
        "12am"
      when 1..11
        hour.to_s + "am"
      when 12
        hour.to_s + "pm"
      when 13..23
        (hour - 12).to_s + "pm"
      end
    end

    # Sorts a given array of 12-hour am/pm values in a clockwise order starting
    # from midnight (like: 12am, 1am, 2am, ..., 11am, 12pm, 1pm, 2pm, ..., 11pm)
    def self.sort_by_12h(hours_array)
      hour_priority_map = {
        "12am" => 1, "1am" => 2, "2am" => 3, "3am" => 4, "4am" => 5, "5am" => 6,
        "6am" => 7, "7am" => 8, "8am" => 9, "9am" => 10, "10am" => 11,
        "11am" => 12, "12pm" => 13, "1pm" => 14, "2pm" => 15, "3pm" => 16,
        "4pm" => 17, "5pm" => 18, "6pm" => 19, "7pm" => 20, "8pm" => 21,
        "9pm" => 22, "10pm" => 23, "11pm" => 24
      }
      arr_with_priorities = hours_array.collect do |hour|
        hour_priority_map[hour]
      end.sort
      return_arr = []
      arr_with_priorities.map do |priority|
        hour_priority_map.each_pair do |hr, pr|
          return_arr << hr if pr == priority
        end
      end.flatten
      return_arr
    end

    # Creates partial meaning (sentence) for the hour field's pattern.
    def self.generate_meaning(list, unit)
      meaning = ""
      meaning += self.field_preposition(unit)
      meaning += " "
      meaning += list.map(&:to_i).map{ |h| self.to_12h(h) }.join(", ")
      meaning
    end
  end
end
