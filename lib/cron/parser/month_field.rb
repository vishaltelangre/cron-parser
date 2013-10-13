class Cron::Parser
  class MonthField < Field
    def self.allowed_values
      ("1".."9").to_a + ("01".."12").to_a + %w{ jan feb mar apr may jun
                                                jul aug sep oct nov dec
                                              }.map(&:upcase)
    end

    def self.allowed_special_characters; %w{ * / , - }             end
    def self.upper_bound;                "1"                       end
    def self.lower_bound;                "12"                      end

    # Adds some month field-specific extra regular expressions to super class's
    # `specifications` method.
    def self.specifications
      extra_specs = [
        {
          rule: /\A
                (?<month>
                (jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)
                )
                \Z/ix,
         yields: ->(month, options) do
           return [month] if options[:exclude_preposition]
           return self.generate_meaning([month], options[:unit])
         end,
         for_fields: %w{ month }
        },
      ]
      super + extra_specs
    end

    # Creates partial meaning (sentence) for the month field's pattern.
    def self.generate_meaning(list, unit)
      meaning = ""
      meaning += self.field_preposition(unit)
      meaning += " "
      meaning += list.map{ |m| self.ascii_month(m) }.join(", ")
      meaning
    end

    # Converts a numerical month value or 3-letter month value to human-readable
    # month value.
    def self.ascii_month(month)
      case month.to_s.downcase
      when "1", "01", "jan";            "January"
      when "2", "02", "feb";            "February"
      when "3", "03", "mar";            "March"
      when "4", "04", "apr";            "April"
      when "5", "05", "may";            "May"
      when "6", "06", "jun";            "June"
      when "7", "07", "jul";            "July"
      when "8", "08", "aug";            "August"
      when "9", "09", "sep";            "September"
      when "10", "oct";                 "October"
      when "11", "nov";                 "November"
      when "12", "dec";                 "December"
      end
    end
  end
end
