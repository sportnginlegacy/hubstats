module Hubstats
  class ApplicationController < ApplicationController

    before_filter :set_time

    private
    def set_time
      cookies[:hubstats_index] ||= 2
      # @start_date = DATE_RANGE_ARRAY[cookies[:hubstats_index].to_i][:date].ago.to_date
      # @end_date = Date.today + 1
      @start_date = cookies[:hubstats_index].split("~~").first.to_date
      @end_date = cookies[:hubstats_index].split("~~").last.to_date
    end
  end
end
