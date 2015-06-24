module Hubstats
  class ApplicationController < ApplicationController

    before_filter :set_time

    private
    def set_time
      if cookies[:hubstats_index] == "null~~null" || cookies[:hubstats_index] == nil
        times = "#{Date.today - 14}~~#{Date.today}"
      else
        times = cookies[:hubstats_index]
      end
      
      @start_date = times.split("~~").first.to_date
      @end_date = times.split("~~").last.to_date + 1
    end
  end
end
