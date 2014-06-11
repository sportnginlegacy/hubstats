module Hubstats
  class Engine < ::Rails::Engine
    isolate_namespace Hubstats

    require 'octokit'

    config.generators do |g|
      g.test_framework :rspec
    end
    
  end
end
