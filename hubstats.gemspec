 $:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hubstats/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hubstats"
  s.version     = Hubstats::VERSION
  s.authors     = ["Elliot Hursh", "Emma Sax"]
  s.email       = ["elliothursh@gmail.com", "emma.sax4@gmail.com"]
  s.homepage    = ""
  s.summary     = "Github Statistics"
  s.description = "Github Statistics"

  s.files         = `git ls-files -z`.split("\x0")
  s.test_files    = s.files.grep(%r{^(test|spec|features)/})

  s.add_dependency "rails", "~> 5.0.1"
  s.add_dependency "rake", "= 12.3.2"
  s.add_dependency "octokit", "~> 4.14"
  s.add_dependency "faraday", "~> 0.15.4"
  s.add_dependency "will_paginate-bootstrap", "~> 1.0"
  s.add_dependency "select2-rails", "~> 3.0"
  s.add_dependency "sass-rails"
  s.add_dependency "bootstrap-datepicker-rails", "~> 1.5"
  s.add_dependency "jquery-rails"

  s.add_development_dependency "mysql2",'~> 0.4.4'
  s.add_development_dependency "rspec-rails",'~> 3.4'
  s.add_development_dependency "rails-controller-testing", "~> 1.0.4"
  s.add_development_dependency "shoulda-matchers", "~> 2.8"
  s.add_development_dependency "factory_bot_rails"
  s.add_development_dependency "faker", "~> 1.6"
  s.add_development_dependency "test-unit", "~> 3.1"
  s.add_development_dependency "pry"
end
