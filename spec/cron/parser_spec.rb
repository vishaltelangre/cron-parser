require 'spec_helper'

describe Cron::Parser do
  let(:parser_klass) { Cron::Parser }

  context "Vroom..." do
    it "check invalid pattern" do
      expect { parser_klass.new }.to raise_error(InvalidCronPatternError, "cron pattern must be a string, please read documentation")
      expect { parser_klass.new("") }.to raise_error(InvalidCronPatternError, "cron pattern must contain exact 5 fields seperated by whitespaces")
    end
  end

  context "Check for individual fields" do
    context "blah" do
    end
  end
end
