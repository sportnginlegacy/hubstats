require_dependency "hubstats/application_controller"

module Hubstats
  class BaseController < Hubstats::ApplicationController

    # grouping
    # params: group_request, group
    #
    # If the group is being asked to be grouped by user or repo, will make an array and group the data
    # by either username or repo name.
    def grouping (group_request, group)
      if group_request == "user"
        @groups = group.to_a.group_by(&:user_name)
      elsif group_request == "repo"
        @groups = group.to_a.group_by(&:repo_name)
      end
    end
  end
end
