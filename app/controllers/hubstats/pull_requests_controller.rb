require_dependency "hubstats/application_controller"

module Hubstats
  class PullRequestsController < ApplicationController

    def index
      URI.decode(params[:label]) if params[:label]

      @pull_requests = Hubstats::PullRequest
        .belonging_to_users(params[:users])
        .belonging_to_repos(params[:repos])
        .with_state(params[:state])
        .state_based_order(@timespan,params[:state],params[:order])

      pull_ids =@pull_requests.map(&:id)
      
      @labels = Hubstats::Label.with_a_pull_request(pull_ids).order("pull_request_count DESC")
      @pull_requests = @pull_requests
        .includes(:user).includes(:repo)
        .with_label(params[:label]).distinct
        .paginate(:page => params[:page], :per_page => 15)
    end 

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_request = Hubstats::PullRequest.belonging_to_repo(@repo.id).where(id: params[:id]).first
      @comments = Hubstats::Comment.belonging_to_pull_request(params[:id]).includes(:user).created_since(@timespan).limit(20)
      @comment_count = Hubstats::Comment.belonging_to_pull_request(params[:id]).includes(:user).created_since(@timespan).count(:all)
      @stats = {
        comment_count: @comment_count,
        avg_additions: @pull_request.additions.to_i,
        avg_deletions: @pull_request.deletions.to_i,
        net_additions: @pull_request.additions.to_i - @pull_request.deletions.to_i
      }
    end

  end
end
