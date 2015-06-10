require_dependency "hubstats/application_controller"

module Hubstats
  class UsersController < ApplicationController

    def index 
      if params[:query] ## For select 2.
        @users = Hubstats::User.where("login LIKE ?", "%#{params[:query]}%").order("login ASC")
      elsif params[:id] ## 
        @users = Hubstats::User.where(id: params[:id].split(",")).order("login ASC")
      else
        @users = Hubstats::User.only_active.with_all_metrics(@timespan).with_id(params[:users]).custom_order(params[:order]).paginate(:page => params[:page], :per_page => 15)
      end
      
      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @users}
      end
    end

    def show
      @user = Hubstats::User.where(login: params[:id]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_user(@user.id).updated_since(@timespan).order("updated_at DESC").limit(20)
      @comments = Hubstats::Comment.belonging_to_user(@user.id).created_since(@timespan).order("created_at DESC").limit(20)
      @deploys = Hubstats::Deploy.belonging_to_user(@user.id).deployed_since(@timespan).order("deployed_at DESC").limit(20)
      @pull_count = Hubstats::PullRequest.belonging_to_user(@user.id).updated_since(@timespan).count(:all)
      @deploy_count = Hubstats::Deploy.belonging_to_user(@user.id).deployed_since(@timespan).count(:all)
      @comment_count = Hubstats::Comment.belonging_to_user(@user.id).created_since(@timespan).count(:all)
      @stats_basics = {
        pull_count: Hubstats::PullRequest.belonging_to_user(@user.id).merged_since(@timespan).count(:all),
        deploy_count: @deploy_count,
        comment_count: @comment_count,
        avg_additions: Hubstats::PullRequest.merged_since(@timespan).belonging_to_user(@user.id).average(:additions).to_i,
        avg_deletions: Hubstats::PullRequest.merged_since(@timespan).belonging_to_user(@user.id).average(:deletions).to_i,
        net_additions: Hubstats::PullRequest.merged_since(@timespan).belonging_to_user(@user.id).sum(:additions).to_i -
          Hubstats::PullRequest.merged_since(@timespan).belonging_to_user(@user.id).sum(:deletions).to_i
      }
    end

  end
end
