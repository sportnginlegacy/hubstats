require_dependency "hubstats/application_controller"

module Hubstats
  class PullRequestsController < Hubstats::BaseController

    # Public - Will correctly add the labels to the side of the page based on which PRs are showing, and will
    # come up with the list of PRs to show, based on users, repos, grouping, labels, and order. Only shows
    # PRs within @start_date and @end_date.
    #
    # Returns - the pull request data
    def index
      URI.decode(params[:label]) if params[:label]

      pull_requests = PullRequest.all_filtered(params, @start_date, @end_date)
      @labels = Hubstats::Label.count_by_pull_requests(pull_requests).order("pull_request_count DESC")

      @pull_requests = Hubstats::PullRequest.includes(:user, :repo, :team)
        .belonging_to_users(params[:users]).belonging_to_repos(params[:repos]).belonging_to_teams(params[:teams])
        .group_by(params[:group]).with_label(params[:label])
        .state_based_order(@start_date, @end_date, params[:state], params[:order])
        .paginate(:page => params[:page], :per_page => 15)

      grouping(params[:group], @pull_requests)
    end 

    # Public - Will show the particular pull request selected, including all of the basic stats, deploy (only if 
    # PR is closed), and comments associated with that PR within the @start_date and @end_date.
    #
    # Returns - the specific details of the pull request
    def show
      @repo = Hubstats::Repo.where(name: params[:repo]).first
      @pull_request = Hubstats::PullRequest.belonging_to_repo(@repo.id).where(id: params[:id]).first
      @comments = Hubstats::Comment.belonging_to_pull_request(params[:id]).created_in_date_range(@start_date, @end_date).limit(50)
      comment_count = Hubstats::Comment.belonging_to_pull_request(params[:id]).created_in_date_range(@start_date, @end_date).count(:all)
      @deploys = Hubstats::Deploy.where(id: @pull_request.deploy_id).order("deployed_at DESC")
      @stats_row_one = {
        comment_count: comment_count,
        net_additions: @pull_request.additions.to_i - @pull_request.deletions.to_i,
        additions: @pull_request.additions.to_i,
        deletions: @pull_request.deletions.to_i
      }
    end
  end
end
