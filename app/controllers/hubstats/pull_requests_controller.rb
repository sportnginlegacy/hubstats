require_dependency "hubstats/application_controller"

module Hubstats
  class PullRequestsController < ApplicationController

    def index
      @pull_requests = Hubstats::PullRequest.includes(:user).includes(:repo)
      if params[:state] == "open" || params[:state] == "closed"
        @pull_requests = @pull_requests.where(state: params[:state])
      end

      if params[:order]
        if params[:state] == "open" || params[:state] == "all"
          @pull_requests= @pull_requests.opened_since(@timespan).order("created_at #{params[:order]}")
        else
          @pull_requests= @pull_requests.closed_since(@timespan).order("closed_at #{params[:order]}")
        end
      else
        if params[:state] == "open" || params[:state] == "all"
          @pull_requests= @pull_requests.opened_since(@timespan).order("created_at DESC")
        else
          @pull_requests= @pull_requests.closed_since(@timespan).order("closed_at DESC")
        end
      end

      if params[:repos]
        @pull_requests = @pull_requests.belonging_to_repos(params[:repos])
      end
      if params[:users]
        @pull_requests = @pull_requests.belonging_to_users(params[:users])
      end

      @pull_requests = @pull_requests.paginate(:page => params[:page], :per_page => 15)
      @labels = Hubstats::Label.with_number_of_pulls
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
