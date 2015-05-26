require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < ApplicationController

# I'll probably need to update the users controller, model, as well so that we can access their deploys
   def index
    #	deploy_ids = Hubstats::Deploy
    #	  .belonging_to(params[:users])
    #	  .belonging_to(params[:repos])
    #	  .state_based_order(@timespan,params[:state],"ASC")
    #	  .map(&:id)

    #	@deploys = Hubstats::Deploy.includes(:user).includes(:repo)
    #	  .belonging_to_users(params[:users]).belonging_to_repos(params[:repos])
    #	  .group_by(params[:group])
    #	  .state_based_order(@timespan,params[:state],params[:order])
    #	  .paginate(:page => params[:page], :per_page => 15)

    #	if params[:group] == 'user'
    #	  @groups = @deploys.to_a.group_by(&:user_name)
    #	elsif params[:group] == 'repo'
    #	  @groups = @deploys.to_a.group_by(&:repo_name)
    #	end
      @deploys = Deploy.all
    end

    def show
    end

  end
 end
