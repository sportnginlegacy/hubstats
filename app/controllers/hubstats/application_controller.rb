module Hubstats
  class ApplicationController < ApplicationController

    before_filter :set_time

    private
    def set_time
      cookies[:hubstats_index] ||= 2
      @timespan = TIMESPAN_ARRAY[cookies[:hubstats_index].to_i][:date].ago.to_date
    end

  end
end
