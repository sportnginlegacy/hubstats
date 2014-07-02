require_dependency "hubstats/application_controller"

module Hubstats
  class ReposController < ApplicationController
    def index
      @repos = Hubstats::Repo.with_recent_activity(@timespan).limit(20)
      @users = Hubstats::User.with_pulls_or_comments(@timespan).only_active.limit(20)
      @stats = {
        user_count: Hubstats::User.with_pulls_or_comments(@timespan).only_active.length,
        pull_count: Hubstats::PullRequest.closed_since(@timespan).count(:all),
        comment_count: Hubstats::Comment.created_since(@timespan).count(:all),
        avg_additions: Hubstats::PullRequest.closed_since(@timespan).average(:additions).to_i,
        avg_deletions: Hubstats::PullRequest.closed_since(@timespan).average(:deletions).to_i,
        net_additions: Hubstats::PullRequest.closed_since(@timespan).sum(:additions).to_i - Hubstats::PullRequest.closed_since(@timespan).sum(:deletions).to_i
      }
    end

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_repo(@repo.id).closed_since(@timespan).order("closed_at DESC").limit(20)
      @users = Hubstats::User.with_pulls_or_comments(@timespan,@repo.id).only_active
      @stats = {
        user_count: @users.length,
        pull_count: Hubstats::PullRequest.belonging_to_repo(@repo.id).closed_since(@timespan).count(:all),
        comment_count: Hubstats::Comment.belonging_to_repo(@repo.id).created_since(@timespan).count(:all),
        avg_additions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_repo(@repo.id).average(:additions).to_i,
        avg_deletions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_repo(@repo.id).average(:deletions).to_i,
        net_additions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_repo(@repo.id).sum(:additions).to_i - Hubstats::PullRequest.closed_since(@timespan).belonging_to_repo(@repo.id).sum(:deletions).to_i
      }
    end
  end
end
