require "hubstats/engine"
require "hub_helper"
require "hubstats/github_api"
require "hubstats/events_handler"
require "active_support/core_ext/numeric"
require "hubstats/config"

module Hubstats
  def self.config
    @@config ||= Hubstats::Config.parse
  end
end
