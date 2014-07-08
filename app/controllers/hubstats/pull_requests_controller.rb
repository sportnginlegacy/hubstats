require_dependency "hubstats/application_controller"

module Hubstats
  class PullRequestsController < ApplicationController

    def index
      @pull_requests = Hubstats::PullRequest.closed_since(@timespan).includes(:user)
      if params[:state] && params[:state] != "all"
        @pull_requests = @pull_requests.where(state: params[:state])
      end
      if params[:order]
        @pull_requests = @pull_requests.order("created_at #{params[:order]}")
      end
      if params[:repos]
        @pull_requests = @pull_requests.belonging_to_repos(params[:repos])
      end
      if params[:users]
        @pull_requests = @pull_requests.belonging_to_user(params[:users])
      end

      @pull_requests = @pull_requests.paginate(:page => params[:page], :per_page => 15)
      @labels = Hubstats::Label.all
    end 

    def repo_index
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_repo(@repo.id).closed_since(@timespan).order("closed_at DESC")
    end

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_request = Hubstats::PullRequest.belonging_to_repo(@repo.id).where(id: params[:id]).first
      @comments = Hubstats::Comment.belonging_to_pull_request(params[:id]).includes(:user).created_since(@timespan)
    end
  end

end
