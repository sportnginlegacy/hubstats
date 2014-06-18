module Hubstats
  class ApplicationController < ActionController::Base

    before_filter :set_time

    private
    def set_time
      @timespan = cookies[:timespan] || 2.weeks.ago.to_date
    end

  end
end
