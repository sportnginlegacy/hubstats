require_dependency "hubstats/application_controller"

module Hubstats
  class BaseController < Hubstats::ApplicationController
  	def grouping (group_request, group)
  		if group_request == "user"
        @groups = group.to_a.group_by(&:user_name)
      elsif group_request == "repo"
        @groups = group.to_a.group_by(&:repo_name)
      end
  	end
  end
end
