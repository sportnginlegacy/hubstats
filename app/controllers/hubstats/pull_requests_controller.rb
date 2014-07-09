require_dependency "hubstats/application_controller"

module Hubstats
  class PullRequestsController < ApplicationController

    def index
      @pull_requests = Hubstats::PullRequest.includes(:user).includes(:repo)
        .belonging_to_users(params[:users])
        .belonging_to_repos(params[:repos])
        .with_state(params[:state])
        .state_based_order(@timespan,params[:state],params[:order])
        .paginate(:page => params[:page], :per_page => 15)
        
      @labels = Hubstats::Label.with_a_pull_request
    end 

    def repo_index
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_repo(@repo.id).closed_since(@timespan).order("closed_at DESC")
    end

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_request = Hubstats::PullRequest.belonging_to_repo(@repo.id).where(id: params[:id]).first
      @comments = Hubstats::Comment.belonging_to_pull_request(params[:id]).includes(:user).created_since(@timespan)
      @stats = {
        github: @pull_request.html_url,
        comment_count: @comments.count(:all),
        additions: @pull_request.additions.to_i,
        deletions: @pull_request.deletions.to_i,
        net_additions: @pull_request.additions.to_i - @pull_request.deletions.to_i
      }
    end

  end
end
