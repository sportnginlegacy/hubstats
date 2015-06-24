module Hubstats
  class ApplicationController < ApplicationController

    before_filter :set_time

    private
    def set_time
      if cookies[:hubstats_dates] == "null~~null" || cookies[:hubstats_dates] == nil
        @start_date = Date.today - 14
        @end_date = Date.today + 1
      else
        @start_date = cookies[:hubstats_dates].split("~~").first.to_date
        @end_date = cookies[:hubstats_dates].split("~~").last.to_date + 1
      end
    end
  end
end
