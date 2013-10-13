class Cron::Parser
  class HourField < Field
    def self.allowed_values; ("0".."9").to_a + ("00".."23").to_a   end
    def self.upper_bound;                self.allowed_values.last  end
    def self.lower_bound;                self.allowed_values.first end
    def self.allowed_special_characters; %w{ * / , - }             end
    def self.specifications
      super
    end

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

    def self.generate_meaning(list, unit)
      meaning = ""
      meaning += self.field_preposition(unit)
      meaning += " "
      meaning += list.map(&:to_i).map{ |h| self.to_12h(h) }.join(", ")
      meaning
    end
  end
end
