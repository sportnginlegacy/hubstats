require_dependency "hubstats/application_controller"

module Hubstats
  class UsersController < ApplicationController

    def index 
      @users = Hubstats::User.where("login LIKE '%#{params[:query]}%'").order("login ASC")

      respond_to do |format|
        format.html # index.html.erb
        format.json { render :json => @users}
      end
    end

    def show
      @user = Hubstats::User.where(login: params[:id]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_user(@user.id).closed_since(@timespan).order("closed_at DESC").limit(20)
      @comments = Hubstats::Comment.belonging_to_user(@user.id).created_since(@timespan).order("created_at DESC").limit(20)
      @review = Hubstats::User.pulls_reviewed_count(@timespan).where(login: params[:id]).first
      @stats = {
        pull_count: Hubstats::PullRequest.belonging_to_user(@user.id).closed_since(@timespan).count(:all),
        comment_count: Hubstats::Comment.belonging_to_user(@user.id).created_since(@timespan).count(:all),
        review_count: @reviews ? reviews_count : 0,
        avg_additions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_user(@user.id).average(:additions).to_i,
        avg_deletions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_user(@user.id).average(:deletions).to_i,
        net_additions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_user(@user.id).sum(:additions).to_i - Hubstats::PullRequest.closed_since(@timespan).belonging_to_user(@user.id).sum(:deletions).to_i
      }
    end

  end
end
