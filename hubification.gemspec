$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "hubification/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "hubification"
  s.version     = Hubification::VERSION
  s.authors     = ["Elliot Hursh"]
  s.email       = ["elliothursh@gmail.com"]
  s.homepage    = ""
  s.summary     = "Gamifiying github"
  s.description = "Gamifiying github"

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", "~> 3.2.18"
  s.add_dependency "octokit"

  s.add_development_dependency "sqlite3"
end
