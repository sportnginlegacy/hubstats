module Hubification
  class Engine < ::Rails::Engine
    isolate_namespace Hubification

    require 'octokit'
  end
end
