module Hubstats
  class ApplicationController < ApplicationController

    before_filter :set_time

    private
    def set_time
      cookies[:hubstats_index] ||= 2
      if TIMESPAN_ARRAY[cookies[:hubstats_index].to_i][:display_value] != "Select date range"
      	@timespan = TIMESPAN_ARRAY[cookies[:hubstats_index].to_i][:date].ago.to_date
      else
      	@timespan = "Select date range"
      end
    end
  end
end
