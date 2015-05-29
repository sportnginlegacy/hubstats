require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < ApplicationController

    def index
      #deploy_id = Hubstats::Deploy
      #  .order_with_timespan(@timespan, "ASC")
      #  .belonging_to_users(params[:users])
      #  .belonging_to_repos(params[:repo])
      #  .has_many_pull_requests(params[:pull_requests])
      #  .map(&:id)

      # sets to include user and repo, and sorts data
      @deploys = Hubstats::Deploy.includes(:user).includes(:repo)
        .order_with_timespan(@timespan, params[:order])
      #  .belonging_to_users(params[:users]).belonging_to_repos(params[:repos])
      #  .paginate(:page => params[:page], :per_page => 15).order("deployed_at DESC")

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

    def create
      if params[:deployed_by].nil? || params[:git_revision].nil? || params[:repo_name].nil?
        render :nothing => true, :status => 400
      else
        @deploy = Deploy.new
        @deploy.deployed_at = params[:deployed_at]
        @deploy.deployed_by = params[:deployed_by]
        @deploy.git_revision = params[:git_revision]
        @deploy.repo_id = Hubstats::Repo.where(full_name: params[:repo_name]).first.id.to_i
        if @deploy.save
          render :nothing =>true, :status => 200
        else
          render :nothing => true, :status => 400
        end
      end
    end

  end
 end
