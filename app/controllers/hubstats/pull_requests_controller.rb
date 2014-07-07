require_dependency "hubstats/application_controller"

module Hubstats
  class PullRequestsController < ApplicationController

    def index
      @pull_requests = Hubstats::PullRequest.closed_since(@timespan).includes(:user)
        .where(state: params[:state]).order("closed_at #{params[:sort]}")

      @labels = Hubstats::Label.all
    end 

    def repo_index
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_requests = Hubstats::PullRequest.belonging_to_repo(@repo.id).closed_since(@timespan)
    end

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_request = Hubstats::PullRequest.belonging_to_repo(@repo.id).where(id: params[:id]).first
      @comments = Hubstats::Comment.belonging_to_pull_request(params[:id]).includes(:user).created_since(@timespan)
    end
  end

end
