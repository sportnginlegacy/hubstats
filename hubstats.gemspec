 $:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hubstats/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hubstats"
  s.version     = Hubstats::VERSION
  s.authors     = ["Elliot Hursh"]
  s.email       = ["elliothursh@gmail.com"]
  s.homepage    = ""
  s.summary     = "Github Statistics"
  s.description = "Github Statistics"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.18"
  s.add_dependency "octokit", "~> 3.2"
  s.add_dependency "will_paginate-bootstrap"
  s.add_dependency "select2-rails", "~> 3.5"
  
  s.add_development_dependency "rspec-rails",'~> 3.0.0.beta'
  s.add_development_dependency "shoulda-matchers", "~> 2.6"
  s.add_development_dependency "factory_girl_rails", "~> 4.4"
  s.add_development_dependency "faker", "~> 1.3"
end
