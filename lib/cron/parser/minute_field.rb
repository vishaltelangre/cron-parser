class Cron::Parser
  class MinuteField < Field
    def self.allowed_values;             0..59         end
    def self.allowed_special_characters; %w{ * / , - } end
    def self.specifications
      [
        {
          # Pattern: "0-10,20-30,40-50/5"
          # Means:   "Every 5 minutes from 0th to 10th,
          #           and 20th to 30th, and 40th to 50th
          #           minute of the hour"
          rule: /\A
                (?<ranges>[0-5]{0,1}[0-9]{1}-[0-5]{0,1}[0-9]{1}[,]{0,1}\g<ranges>*)
                \/
                (?<step_value>[0-9]+)
                \Z/x,
          # More about \g<name> syntax:
          # ruby_1_9_3_core/Regexp.html#label-Subexpression+Calls
          meaning: ->(ranges, step_value) {
            ranges = ranges.split(",").map do |range|
              range.split("-").map(&:ordinalize).join(" to ")
            end.join(", ")
            "Every #{step_value} minutes from #{ranges} minute of the hour"
          }
        },
        {
          # Pattern: "*/15"
          # Means:   "Every 15 minutes"
          rule: /\A\*\/(?<step_value>[0-9]+)\Z/,
          meaning: ->(step_value) { "Every #{step_value} minutes" }
        },
        {
          # Pattern: "1,2,3,5,8,13,21,34,55"
          # Means:   "At 1st, 2nd, 3rd, 5th, 8th, 13th, 21st, 34th,
          #           55th minute of the hour"
          rule: /\A(?<list>[0-5]{0,1}[0-9]{1}[,]{0,1}\g<list>*)\Z/,
          meaning: ->(list) {
            list = list.split(",").map(&:ordinalize).join(", ")
            "At #{list} minute of the hour"
          }
        },
        {
          # Pattern: "*"
          # Means:   "Every minute"
          rule: /\A\*\Z/,
          meaning: ->() { "Every minute" }
        }
      ]
    end
  end
end
