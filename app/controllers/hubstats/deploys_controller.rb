require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < ApplicationController

   def index
        deploy_id = Hubstats::Deploy
          .order_with_timespan(@timespan, "ASC")
      #   .belonging_to_users(params[:users])
     #    .belonging_to_repos(params[:repo])
     #    .has_many_pull_requests(params[:pull_requests])
    #     .map(&:id)

        # sets to include user and repo, and sorts data
        @deploys = Hubstats::Deploy.includes(:user).includes(:repo)
           .order_with_timespan(@timespan, params[:order])
          #.belonging_to_users(params[:users]).belonging_to_repos(params[:repos])
         # .paginate(:page => params[:page], :per_page => 15).order("deployed_at DESC")

        if params[:group] == 'user'
          @groups = @deploys.to_a.group_by(&:user_name)
        elsif params[:group] == 'repo'
          @groups = @deploys.to_a.group_by(&:repo_name)
        else
          @groups = nil
        end
    end

    def show
    end

    # create should be run on a post route whenever a deploy is made (we get deploys from new relic)
    def create(revision, repo_name, time=Time.now.getutc, username)
        @deployed_by = username
        @git_revision = revision
        @repo_id = Hubstats::Repo.where(full_name: repo_name).first.id
        @time = time
    end

  end
 end
