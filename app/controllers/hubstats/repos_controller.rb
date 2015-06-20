require_dependency "hubstats/application_controller"

module Hubstats
  class ReposController < ApplicationController

    def index
      if params[:query]
        @repos = Hubstats::Repo.where("name LIKE ?", "%#{params[:query]}%").order("name ASC")
      elsif params[:id]
        @repos = Hubstats::Repo.where(id: params[:id].split(",")).order("name ASC")
      else
        @repos = Hubstats::Repo.with_recent_activity(@start_date, @end_date)
      end

      respond_to do |format|
        format.json { render :json => @repos}
      end
    end

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_repo(@repo.id).merged_since(@start_date, @end_date).order("updated_at DESC").limit(20)
      @pull_count = Hubstats::PullRequest.belonging_to_repo(@repo.id).merged_since(@start_date, @end_date).count(:all)
      @deploys = Hubstats::Deploy.belonging_to_repo(@repo.id).deployed_since(@start_date, @end_date).order("deployed_at DESC").limit(20)
      @deploy_count = Hubstats::Deploy.belonging_to_repo(@repo.id).deployed_since(@start_date, @end_date).count(:all)
      @comment_count = Hubstats::Comment.belonging_to_repo(@repo.id).created_since(@start_date, @end_date).count(:all)
      @user_count = Hubstats::User.with_pulls_or_comments(@start_date, @end_date, @repo.id).only_active.length
      @net_additions = Hubstats::PullRequest.merged_since(@start_date, @end_date).belonging_to_repo(@repo.id).sum(:additions).to_i -
                       Hubstats::PullRequest.merged_since(@start_date, @end_date).belonging_to_repo(@repo.id).sum(:deletions).to_i
      @additions = Hubstats::PullRequest.merged_since(@start_date, @end_date).belonging_to_repo(@repo.id).average(:additions)
      @deletions = Hubstats::PullRequest.merged_since(@start_date, @end_date).belonging_to_repo(@repo.id).average(:deletions)
      
      stats
    end

    def dashboard
      if params[:query] ## For select 2.
        @repos = Hubstats::Repo.where("name LIKE ?", "%#{params[:query]}%").order("name ASC")
      elsif params[:id]
        @repos = Hubstats::Repo.where(id: params[:id].split(",")).order("name ASC")
      else
        @repos = Hubstats::Repo.with_all_metrics(@start_date, @end_date)
          .with_id(params[:repos])
          .custom_order(params[:order])
          .paginate(:page => params[:page], :per_page => 15)
      end

      @user_count = Hubstats::User.with_pulls_or_comments(@start_date, @end_date).only_active.length
      @deploy_count = Hubstats::Deploy.deployed_since(@start_date, @end_date).count(:all)
      @pull_count = Hubstats::PullRequest.merged_since(@start_date, @end_date).count(:all)
      @comment_count = Hubstats::Comment.created_since(@start_date, @end_date).count(:all)
      @net_additions = Hubstats::PullRequest.merged_since(@start_date, @end_date).sum(:additions).to_i - 
                       Hubstats::PullRequest.merged_since(@start_date, @end_date).sum(:deletions).to_i
      @additions = Hubstats::PullRequest.merged_since(@start_date, @end_date).average(:additions)
      @deletions = Hubstats::PullRequest.merged_since(@start_date, @end_date).average(:deletions)

      stats

      respond_to do |format|
        format.html
        format.json { render :json => @repos}
      end
    end

    def stats
      @additions ||= 0
      @deletions ||= 0
      @stats_basics = {
        user_count: @user_count,
        deploy_count: @deploy_count,
        pull_count: @pull_count,
        comment_count: @comment_count
      }
      @stats_additions = {
        avg_additions: @additions.round.to_i,
        avg_deletions: @deletions.round.to_i,
        net_additions: @net_additions
      }
    end
  end
end
