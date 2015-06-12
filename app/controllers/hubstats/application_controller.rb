module Hubstats
  class ApplicationController < ApplicationController

    before_filter :set_time

    private
    def set_time
      cookies[:hubstats_index] ||= 2
      @timespan = TIMESPAN_ARRAY[cookies[:hubstats_index].to_i][:date].ago.to_date
    end

    def grouping (group_request, group)
      if group_request == "user"
        @groups = group.to_a.group_by(&:user_name)
      elsif group_request == "repo"
        @groups = group.to_a.group_by(&:repo_name)
      end
    end
  end
end
