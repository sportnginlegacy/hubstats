require_dependency "hubstats/application_controller"

module Hubstats
  class ReposController < ApplicationController
    def index
      @repos = Hubstats::Repo.with_recent_activity
      @users = Hubstats::User.pull_requests_and_comments
      @stats = {
        user_count: Hubstats::User.count(:all),
        pull_count: Hubstats::PullRequest.closed_since(2.weeks.ago).count(:all),
        comment_count: Hubstats::Comment.created_since(2.weeks.ago).count(:all)
      }
    end

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_repo(@repo.id).closed_since(2.weeks.ago)
      @users = Hubstats::User.pull_requests_and_comments
      @stats = {
        user_count: Hubstats::User.count(:all),
        pull_count: Hubstats::PullRequest.belonging_to_repo(@repo.id).closed_since(2.weeks.ago).count(:all),
        comment_count: Hubstats::Comment.created_since(2.weeks.ago).count(:all)
      }
    end
  end
end
