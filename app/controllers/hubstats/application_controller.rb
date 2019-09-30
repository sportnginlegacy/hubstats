module Hubstats
  class ApplicationController < ::ApplicationController
    before_action :set_time

    # Private - Reads the cookie, and then either sets @start_date and @end_date to be the cookie's values
    # or sets them to be today + 1 and two weeks ago.
    #
    # Returns -  nothing
    private def set_time
      cookie = cookies[:hubstats_dates]
      if cookie == nil || cookie.include?("null")
        @start_date = Date.today - 14
        @end_date = Date.today + 1
      else
        @start_date = cookies[:hubstats_dates].split("~~").first.to_date
        @end_date = cookies[:hubstats_dates].split("~~").last.to_date + 1
      end
    end
  end
end
