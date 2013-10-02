require_relative "extras/string_extensions"
require_relative "cron/parser"
require_relative "cron/parser/field"
require_relative "cron/parser/minute_field"
require_relative "cron/parser/hour_field"
require_relative "cron/parser/day_of_month_field"
require_relative "cron/parser/month_field"
require_relative "cron/parser/day_of_week_field"
# Dir.glob(File.join(File.dirname(__FILE__), "**", "*.rb")).each { |file| require file }

class Cron; end

InvalidPatternError = Class.new(ArgumentError)