require 'spec_helper'

class Cron
  describe Parser do

    let(:parser_klass) { Cron::Parser }

    spec_fields = %w{ minute hour day_of_month month day_of_week }

    it "should check invalid pattern" do
      expect { parser_klass.new }.to raise_error(InvalidCronPatternError, /cron pattern must be a string/)
      expect { parser_klass.new("") }.to raise_error(InvalidCronPatternError, /cron pattern must contain exact/)
    end

    context "initialized with correct pattern" do
      subject { parser_klass.new("* * * * *") }

      specify { expect(subject).to be_an_instance_of(parser_klass) }

      specify { should have_exactly(5).fields }

      it "should respond to all public instance methods" do
        methods = [:pattern, :fields, :meaning, :warnings, :humanize, :inspect] + spec_fields.map(&:to_sym).map { |f| f = "#{f}_field" }
        methods.each do |method|
          subject.should respond_to(method)
        end
      end # respond to public instance methods

      context "checks each instance field" do
        it "check minute_field instance" do
          expect(subject.minute_field).to eq(subject.fields[:minute])
        end
        it "check hour_field instance" do
          expect(subject.hour_field).to eq(subject.fields[:hour])
        end
        it "check day_of_month_field instance" do
          expect(subject.day_of_month_field).to eq(subject.fields[:day_of_month])
        end
        it "check month_field instance" do
          expect(subject.month_field).to eq(subject.fields[:month])
        end
        it "check day_of_week_field instance" do
          expect(subject.day_of_week_field).to eq(subject.fields[:day_of_week])
        end
      end # context each instance field
    end # context correct pattern

    context "well, start with kind of patterns..." do
      context "wrong patterns tests" do

        describe "minute" do
          wrong_min_patterns = ["-1 * * * *", "3- * * * *", "60 * * * *", "1,2,b * * * *", "1-03,3/,6 * * * *", "5--6, * * * *", "(2,3),5 * * * *"]
          wrong_min_patterns.each do |pattern|
            it "for PATTERN: \"#{pattern}\" it raises error" do
              expect { parser_klass.new(pattern) }.to raise_error(InvalidMinuteFieldError)
            end
          end
        end # context wrong minute pattern

        describe "hour" do
          wrong_hr_patterns = ["* -1 * * *", "* 3- * * *", "* 24 * * *", "* 1pm * * *", "* 3/,4 * * *", "* 5--10 * * *", "* 20%5 * * *"]
          wrong_hr_patterns.each do |pattern|
            it "for PATTERN: \"#{pattern}\" it raises error" do
              expect { parser_klass.new(pattern) }.to raise_error(InvalidHourFieldError)
            end
          end
        end # context wrong hour pattern

        describe "day_of_month" do
          wrong_dom_patterns = ["* * 0 * *", "* * -1 * *", "* * 3- * *", "* * 32 * *", "* * 1st * *", "* * 3/,5,6 * *", "* * 5--10 * *", "* * 2^2 * *"]
          wrong_dom_patterns.each do |pattern|
            it "for PATTERN: \"#{pattern}\" it raises error" do
              expect { parser_klass.new(pattern) }.to raise_error(InvalidDayOfMonthFieldError)
            end
          end
        end # context wrong day_of_month pattern

        describe "month" do
          wrong_mnth_patterns = ["* * * 0 *", "* * * -1 *", "* * * 3- *", "* * * 13 *", "* * * MARC *", "* * * 1st *", "* * * 3/,5,6 *", "* * * 5--10 *", "* * * @ *"]
          wrong_mnth_patterns.each do |pattern|
            it "for PATTERN: \"#{pattern}\" it raises error" do
              expect { parser_klass.new(pattern) }.to raise_error(InvalidMonthFieldError)
            end
          end
        end # context wrong month pattern

        describe "day_of_week" do
          wrong_dow_patterns = ["* * * * -1", "* * * * 3-", "* * * * 8", "* * * * sunday", "* * * * 2nd", "* * * * 3/", "* * * * 1--6", "* * * * %"]
          wrong_dow_patterns.each do |pattern|
            it "for PATTERN: \"#{pattern}\" it raises error" do
              expect { parser_klass.new(pattern) }.to raise_error(InvalidDayOfWeekFieldError)
            end
          end
        end # context wrong day_of_week pattern
      end # context invalid patterns' tests

      context "valid patterns tests" do

        def test_valid_pattern(pattern = "", meaning = "", warnings = [])
          parsed_obj = parser_klass.new(pattern)
          parsed_obj.meaning.should == meaning
          parsed_obj.warnings.should == warnings
        end

        valid_data = [
          ["* * * * *", "every minute; every hour; every day of month; every month; every day of week", []],
          ["04 * * * *", "at 4th minute; every hour; every day of month; every month; every day of week", []],
          ["5 0 * * *", "at 5th minute; on 12am; every day of month; every month; every day of week", []],
          ["15 14 1 * *", "at 15th minute; on 2pm; on days: 1st; every month; every day of week", []],
          ["0 22 * * 1-5", "at 0th minute; on 10pm; every day of month; every month; on Monday, Tuesday, Wednsday, Thursday, Friday", []],
          ["23 0-23/2 * * *", "at 23rd minute; on 12am, 2am, 4am, 6am, 8am, 10am, 12pm, 2pm, 4pm, 6pm, 8pm, 10pm; every day of month; every month; every day of week", []],
          ["5 4 * * sun", "at 5th minute; on 4am; every day of month; every month; on Sunday", []],
          ["0 4 8-14 * *", "at 0th minute; on 4am; on days: 8th, 9th, 10th, 11th, 12th, 13th, 14th; every month; every day of week", []],
          ["5-12,1,59 4-10/2,11 */6,28,29 1-3,Nov,Dec *", "at 1st, 5th, 6th, 7th, 8th, 9th, 10th, 11th, 12th, 59th minute; on 4am, 6am, 8am, 10am, 11am; on days: 6th, 12th, 18th, 24th, 28th, 29th, 30th; in January, February, March, December, November; every day of week", []],
          ["38,37/40,39 1/2,3 26,27/2,30,31 * MON", "at 37th, 38th minute; on 1am; on days: 26th, 27th; every month; on Monday", ["for 'minute' field: '37/40' is valid but confusing pattern", "for 'hour' field: '1/2' is valid but confusing pattern", "for 'day_of_month' field: '27/2' is valid but confusing pattern"]],
        ]

        valid_data.map do |item|
          pattern, meaning, warnings = item
          display_msg  = "for PATTERN: \"#{pattern}\""
          display_msg += "\n\tmeaning: \"#{meaning}\""
          display_msg += "\n\twarnings: #{warnings}" if warnings.any?

          it display_msg do
            test_valid_pattern(pattern, meaning, warnings)
          end
        end

      end # context valid patterns' tests
    end # context start with kind of patterns
  end # describe Parser
end # class Cron