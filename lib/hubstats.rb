require "hubstats/engine"
require "hub_helper"
require "hubstats/github_api"
require "hubstats/events_handler"
require "active_support/core_ext/numeric"
require "hubstats/config"

module Hubstats
  # Public - Sets the config for the webhook to correctly receive and match the signatures
  #
  # DO NOT DELETE
  #
  # Returns - nothing
  def self.config
    @@config ||= Hubstats::Config.parse
  end
end
