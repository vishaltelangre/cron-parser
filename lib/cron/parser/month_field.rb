class Cron::Parser
  class MonthField < Field
    def self.allowed_values
      ("1".."12").to_a + %w{ jan feb mar apr may jun
                             jul aug sep oct nov dec
                           }
    end
    
    def self.upper_bound;                "1"                       end
    def self.lower_bound;                "12"                      end
    def self.allowed_special_characters; %w{ * / , - }             end
    def self.specifications
      super
    end

    def self.generate_meaning(list, unit)
      meaning = ""
      meaning += self.field_preposition(unit)
      meaning += " "
      meaning += list.map{ |m| self.ascii_month(m.to_i) }.join(", ")
      meaning
    end

    def self.ascii_month(month)
      months = %w{ jan feb mar apr may jun
                   jul aug sep oct nov dec
                 }
      months[month+1].capitalize
    end
  end
end
