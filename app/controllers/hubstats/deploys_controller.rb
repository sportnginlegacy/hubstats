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

    #create should be run on a post route whenever a deploy is made (we get deploys from new relic)
    def create(revision, repo_name, time=Time.now.getutc, username) #if the time isn't provided, get the current time
        @deployed_by = username
        @git_revision = revision
        @repo_id = Repo.where(full_name: repo_name).first.id
        @repo_name = Repo.where(full_name: repo_name).first.name
        @time = time
    end

  end
 end
