module Hubification
  class Engine < ::Rails::Engine
    isolate_namespace Hubification

    require 'octokit'

    config.generators do |g|
      g.test_framework :rspec
    end
    
  end
end
