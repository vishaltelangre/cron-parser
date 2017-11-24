Cron::Parser
============

[![Gem Version](https://badge.fury.io/rb/cron-parser.png)](http://badge.fury.io/rb/cron-parser)
[![Build Status](https://travis-ci.org/vishaltelangre/cron-parser.png?branch=master)](https://travis-ci.org/vishaltelangre/cron-parser)

Dissect your Cron pattern!

## Installation

Install gem by using following command:

    gem install cron-parser

or add it to your Gemfile as:

```ruby
gem 'cron-parser', require: 'cron'
```

## Usage

Well, using `Cron::Parser` is really easy, take a look at following example:

```ruby
require 'cron'

# so you have got a pattern, which you want to dissect:
dirty_cron_pattern = "38,37/40,39 */6,01,2 21-30/3,30,31 * MON,2-4"

# ask `Cron::Parser` to dissect it, and it will do that nasty job for you:

>> parsed_pattern = Cron::Parser.new(dirty_cron_pattern)
# => #<Cron::Parser:0x973860c> { :pattern => "38,37/40,39 */6,01,2 21-30/3,30,31 * MON,2-4", :fields => {:minute=>#<Cron::Parser::MinuteField:0x9736ab4> { :pattern => "38,37/40,39", :warning => '37/40' is valid but confusing pattern, :meaning => "at 37th, 38th minute" }, :hour=>#<Cron::Parser::HourField:0x9743bd8> { :pattern => "*/6,01,2", :meaning => "on 12am, 1am, 2am, 6am, 12pm, 6pm" }, :day_of_month=>#<Cron::Parser::DayOfMonthField:0x9537768> { :pattern => "21-30/3,30,31", :meaning => "on days: 21st, 24th, 27th, 30th, 30th, 31st" }, :month=>#<Cron::Parser::MonthField:0x9586110> { :pattern => "*", :meaning => "every month" }, :day_of_week=>#<Cron::Parser::DayOfWeekField:0x958f224> { :pattern => "MON,2-4", :meaning => "on Tuesday, Wednsday, Thursday, Monday" }} }

# you can do it other way too, if you like:

>> Cron::Parser.parse(dirty_cron_pattern)
# => "at 37th, 38th minute; on 12am, 1am, 2am, 6am, 12pm, 6pm; on days: 21st, 24th, 27th, 30th, 30th, 31st; every month; on Tuesday, Wednsday, Thursday, Monday"

# this is same as below:

>> parsed_pattern.meaning
# => "at 37th, 38th minute; on 12am, 1am, 2am, 6am, 12pm, 6pm; on days: 21st, 24th, 27th, 30th, 30th, 31st; every month; on Tuesday, Wednsday, Thursday, Monday"

# also, `parsed_pattern.humanize` produces the same result as above.

# further exploration methods you can use:

>> parsed_pattern.fields
# => {:minute=>#<Cron::Parser::MinuteField:0x9736ab4> { :pattern => "38,37/40,39", :warning => '37/40' is valid but confusing pattern, :meaning => "at 37th, 38th minute" }, :hour=>#<Cron::Parser::HourField:0x9743bd8> { :pattern => "*/6,01,2", :meaning => "on 12am, 1am, 2am, 6am, 12pm, 6pm" }, :day_of_month=>#<Cron::Parser::DayOfMonthField:0x9537768> { :pattern => "21-30/3,30,31", :meaning => "on days: 21st, 24th, 27th, 30th, 30th, 31st" }, :month=>#<Cron::Parser::MonthField:0x9586110> { :pattern => "*", :meaning => "every month" }, :day_of_week=>#<Cron::Parser::DayOfWeekField:0x958f224> { :pattern => "MON,2-4", :meaning => "on Tuesday, Wednsday, Thursday, Monday" }}

>> parsed_pattern.minute_field
# => #<Cron::Parser::MinuteField:0x9736ab4> { :pattern => "38,37/40,39", :warning => '37/40' is valid but confusing pattern, :meaning => "at 37th, 38th minute" }

# similarly, see: `parsed_pattern.hour_field`, `parsed_pattern.day_of_month_field`, `parsed_pattern.month_field`, `parsed_pattern.day_of_week_field`

>> parsed_pattern.minute_field.pattern
# => "38,37/40,39"

>> parsed_pattern.minute_field.meaning
# => "at 37th, 38th minute"

>> parsed_pattern.minute_field.warning
# => "'37/40' is valid but confusing pattern"

>> parsed_pattern.warnings
# => ["for 'minute' field: '37/40' is valid but confusing pattern"]
```

What about wrong or invalid patterns, huh?

```ruby
>> Cron::Parser.new(1)
# raises InvalidCronPatternError: cron pattern must be a string

>> Cron::Parser.new("* * *")
# raises InvalidCronPatternError: cron pattern must contain exact 5 fields seperated by whitespaces

>> Cron::Parser.new("* * * * 1-10")
# raises InvalidDayOfWeekFieldError: value: '10' not allowed for 'day_of_week' field, run: 'Cron::Parser::DayOfWeekField.allowed_values' to know valid values

>> Cron::Parser::DayOfWeekField.allowed_values
# => ["0", "1", "2", "3", "4", "5", "6", "7", "00", "01", "02", "03", "04", "05", "06", "07", "SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"]

>> Cron::Parser::DayOfWeekField.allowed_special_characters
# => ["*", "/", ",", "-"]
```

## Important Notes
* This parser is based upon the specifications of `crontab(5)`.
* Following are the pattern fields, and respective allowed values:

```
    *    *    *    *    *
    ┬    ┬    ┬    ┬    ┬
    │    │    │    │    │
    │    │    │    │    │
    │    │    │    │    └───── day_of_week (0-7) (0 or 7 is Sun, or use 3-letter names)
    │    │    │    └────────── month (1-12, or use 3-letter names)
    │    │    └─────────────── day_of_month (1-31)
    │    └──────────────────── hour (0-23)
    └───────────────────────── minute (0-59)
```

* When specifying day of week, both day 0 and day 7 will be considered Sunday.
* Ranges & Lists of numbers are allowed.
* Ranges or lists of names are not allowed.
* Ranges can include 'steps', so `1-9/2` is the same as `1,3,5,7,9`.
* Months or days of the week can be specified by name.
* Use the first three letters of the particular day or month (case doesn't matter).

## Contributing

You're encouraged to contribute to this gem.

* Fork this project.
* Make changes, write tests (run `rake` to check existing test coverage).
* Report bugs, comment on and close open issues.
* Update [CHANGELOG](CHANGELOG.md).
* Make a pull request, bonus points for topic branches.

## Copyright and License

Copyright (c) 2013, Vishal Telangre and [Contributors](CHANGELOG.md). All Rights Reserved.

This project is licenced under the [MIT License](LICENSE.md).
