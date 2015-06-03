module Hubstats
  class Engine < ::Rails::Engine
    isolate_namespace Hubstats

    initializer :assets do |config|
      Rails.application.config.assets.paths << root.join("app", "assets", "fonts")
    end

    config.to_prepare do
      Dir.glob(Rails.root + "app/decorators/**/*_decorator*.rb").each do |c|
        require_dependency(c)
      end
    end

    require "octokit"
    require "select2-rails"
    require "will_paginate-bootstrap"

    config.generators do |g|
      g.test_framework :rspec
    end
    
  end
end
