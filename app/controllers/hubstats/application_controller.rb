module Hubstats
  class ApplicationController < ActionController::Base

    before_filter :create_time_array, :set_time

    private
    def set_time
      @timespan = @timespan_array[cookies[:hubstats_index].to_i][:date] || 2.weeks.ago.to_date
    end

    def create_time_array
      @timespan_array = [
        {
          display_value: "Today",
          date: 1.day.ago.to_date
        },{
          display_value: "One Week",
          date: 1.week.ago.to_date
        },{
          display_value: "Two Weeks",
          date: 2.weeks.ago.to_date
        },{
          display_value: "One Month",
          date: 1.month.ago.to_date
        },{
          display_value: "Three Months",
          date: 3.months.ago.to_date
        },{
          display_value: "Six Months",
          date: 6.months.ago.to_date
        },{
          display_value: "All Time",
          date: 19.years.ago.to_date
        }
      ]
    end
  end
end
