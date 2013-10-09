$:.push File.expand_path("../lib", __FILE__)
$:.push File.expand_path("../lib/extras", __FILE__)
$:.push File.expand_path("../lib/cron", __FILE__)
$:.push File.expand_path("../lib/cron/parser", __FILE__)

require "cron/parser/version"

Gem::Specification.new do |s|
  s.name = "cron-parser"
  s.version = Cron::Parser::VERSION
  s.authors = [ "Vishal Telangre" ]
  s.email = "the@vishaltelangre.com"
  s.platform = Gem::Platform::RUBY
  s.required_rubygems_version = '>= 1.3.6'
  s.files = `git ls-files`.split("\n")
  s.require_paths = [ "lib", "lib/extras", "lib/cron", "lib/cron/parser" ]
  s.homepage = "http://github.com/vishaltelangre/cron-parser"
  s.licenses = [ "MIT" ]
  s.summary = "Dissect your Cron patterns!"
  s.add_development_dependency "rake", "~>0.9.2.2"
  s.add_development_dependency "rspec"
  s.add_dependency "activesupport"
end
