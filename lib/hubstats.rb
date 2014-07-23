require "hubstats/engine"
require "hub_helper"
require "hubstats/github_api"
require "hubstats/events_handler"
require "active_support/core_ext/numeric"
require "hubstats/config"


module Hubstats

  TIMESPAN_ARRAY = [
    {
      display_value: "Today",
      date: 1.day
    },{
      display_value: "One Week",
      date: 1.week
    },{
      display_value: "Two Weeks",
      date: 2.weeks
    },{
      display_value: "One Month",
      date: 4.weeks
    },{
      display_value: "Three Months",
      date: 12.weeks
    },{
      display_value: "Six Months",
      date: 24.weeks
    },{
      display_value: "All Time",
      date: 520.weeks
    }
  ]

  def self.config
    @@config ||= Hubstats::Config.parse
  end
end
