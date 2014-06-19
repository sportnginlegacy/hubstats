module Hubstats
  class ApplicationController < ActionController::Base

    before_filter :set_time

    private
    def set_time
      @timespan = TIMESPAN_ARRAY[cookies[:hubstats_index].to_i][:date].ago.to_date || 2.weeks.ago.to_date
    end

  end
end
