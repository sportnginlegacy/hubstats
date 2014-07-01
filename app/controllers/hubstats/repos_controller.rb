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
        avg_additions: Hubstats::PullRequest.closed_since(@timespan).average(:additions).round,
        avg_deletions: Hubstats::PullRequest.closed_since(@timespan).average(:deletions).round,
        net_additions: Hubstats::PullRequest.closed_since(@timespan).sum(:additions).round - Hubstats::PullRequest.closed_since(@timespan).sum(:deletions).round
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
        avg_additions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_repo(@repo.id).average(:additions).round,
        avg_deletions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_repo(@repo.id).average(:deletions).round,
        net_additions: Hubstats::PullRequest.closed_since(@timespan).belonging_to_repo(@repo.id).sum(:additions).round - Hubstats::PullRequest.closed_since(@timespan).belonging_to_repo(@repo.id).sum(:deletions).round
      }
    end
  end
end
