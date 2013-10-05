class Cron::Parser
  class MinuteField < Field
    def self.allowed_values;             ("0".."59").to_a          end
    def self.upper_bound;                self.allowed_values.first end
    def self.lower_bound;                self.allowed_values.last  end
    def self.allowed_special_characters; %w{ * / , - }             end
    def self.specifications
      super
    end
  end
end
