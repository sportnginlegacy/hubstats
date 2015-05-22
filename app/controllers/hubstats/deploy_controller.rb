require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < ApplicationController

# I'll probably need to update the users controller, model, as well so that we can access their deploys
  	def index
  		@git_rivision = nil
  		@repo_id = nil
  		@deployed_at = nil
  		@deployed_by = nil
  		@user = nil
  		@repo = nil
  		@pull_requests = []
  	end

  	def show
  	end

  end
 end
