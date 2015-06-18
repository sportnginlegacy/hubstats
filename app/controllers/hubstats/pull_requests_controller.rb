require_dependency "hubstats/application_controller"

module Hubstats
  class PullRequestsController < Hubstats::BaseController

    def index
      URI.decode(params[:label]) if params[:label]

      pull_requests = PullRequest.all_filtered(params, @timespan)
      @labels = Hubstats::Label.count_by_pull_requests(pull_requests).order("pull_request_count DESC")

      @pull_requests = Hubstats::PullRequest.includes(:user, :repo)
        .belonging_to_users(params[:users]).belonging_to_repos(params[:repos])
        .group_by(params[:group]).with_label(params[:label])
        .state_based_order(@timespan,params[:state],params[:order])
        .paginate(:page => params[:page], :per_page => 15)

      grouping(params[:group], @pull_requests)
    end 

    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_request = Hubstats::PullRequest.belonging_to_repo(@repo.id).where(id: params[:id]).first
      @comments = Hubstats::Comment.belonging_to_pull_request(params[:id]).created_since(@timespan).limit(20)
      comment_count = Hubstats::Comment.belonging_to_pull_request(params[:id]).created_since(@timespan).count(:all)
      @deploys = Hubstats::Deploy.where(id: @pull_request.deploy_id).order("deployed_at DESC")
      @stats_basics = {
        comment_count: comment_count,
        net_additions: @pull_request.additions.to_i - @pull_request.deletions.to_i,
        additions: @pull_request.additions.to_i,
        deletions: @pull_request.deletions.to_i
      }
    end

  end
end
