require_dependency "hubstats/application_controller"

module Hubstats
  class ReposController < ApplicationController

    def index
      if params[:query]
        @repos = Hubstats::Repo.where("name LIKE ?", "%#{params[:query]}%").order("name ASC")
      elsif params[:id]
        @repos = Hubstats::Repo.where(id: params[:id].split(",")).order("name ASC")
      else
        @repos = Hubstats::Repo.with_recent_activity(@timespan)
      end

      respond_to do |format|
        format.html # show.html.erb
        format.json { render :json => @repos}
      end
    end

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_repo(@repo.id).updated_since(@timespan).order("updated_at DESC").limit(20)
      @users = Hubstats::User.with_pulls_or_comments(@timespan,@repo.id).only_active.limit(20)
      @pull_count = Hubstats::PullRequest.belonging_to_repo(@repo.id).updated_since(@timespan).count(:all)
      @user_count = Hubstats::User.with_pulls_or_comments(@timespan,@repo.id).only_active.length
      @stats = {
        user_count: @user_count,
        pull_count: @pull_count,
        comment_count: Hubstats::Comment.belonging_to_repo(@repo.id).created_since(@timespan).count(:all),
        avg_additions: Hubstats::PullRequest.merged_since(@timespan).belonging_to_repo(@repo.id).average(:additions).to_i,
        avg_deletions: Hubstats::PullRequest.merged_since(@timespan).belonging_to_repo(@repo.id).average(:deletions).to_i,
        net_additions: Hubstats::PullRequest.merged_since(@timespan).belonging_to_repo(@repo.id).sum(:additions).to_i -
          Hubstats::PullRequest.merged_since(@timespan).belonging_to_repo(@repo.id).sum(:deletions).to_i
      }
    end

    def dashboard
      @repos = Hubstats::Repo.with_recent_activity(@timespan).limit(20)
      @users = Hubstats::User.with_pulls_or_comments(@timespan).only_active.limit(20)
      @repo_count = Hubstats::Repo.with_recent_activity(@timespan).count(:all)
      @user_count = Hubstats::User.with_pulls_or_comments(@timespan).only_active.length
      @stats = {
        user_count: @user_count,
        pull_count: Hubstats::PullRequest.merged_since(@timespan).count(:all),
        comment_count: Hubstats::Comment.created_since(@timespan).count(:all),
        avg_additions: Hubstats::PullRequest.merged_since(@timespan).average(:additions).to_i,
        avg_deletions: Hubstats::PullRequest.merged_since(@timespan).average(:deletions).to_i
      }
    end
  end
end
