require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < Hubstats::BaseController

    # Public - Will list the deploys that correspond with selected repos, users, orders, and groupings. Only shows
    # deploys within the @start_date and @end_date.
    #
    # Returns - the deploy data
    def index
      if params[:teams]
        teams = Hubstats::Team.where(id: params[:teams].split(','))
        user_list = teams.map {|team| team.users}.flatten.uniq
      end

      @deploys = Hubstats::Deploy.includes(:repo, :pull_requests, :user)
        .belonging_to_users(params[:users]).belonging_to_repos(params[:repos]).belonging_to_teams(user_list)
        .group_by(params[:group])
        .order_with_date_range(@start_date, @end_date, params[:order])
        .paginate(:page => params[:page], :per_page => 15)

      grouping(params[:group], @deploys)
    end

    # Public - Shows the single deploy and all of the stats and pull requests about that deploy. Stats and PRs only
    # include info that happened between @start_date and @end_date.
    #
    # Returns - the stats and data of the deploy
    def show
      @deploy = Hubstats::Deploy.includes(:repo, :pull_requests).find(params[:id])
      repo = @deploy.repo
      @pull_requests = @deploy.pull_requests.limit(20)
      @pull_request_count = @pull_requests.length
      @stats_row_one = {
        pull_count: @pull_request_count,
        net_additions: @deploy.find_net_additions,
        comment_count: @deploy.find_comment_count,
        additions: @deploy.total_changes(:additions),
        deletions: @deploy.total_changes(:deletions)
      }
    end

    # Public - Creates a new deploy with the git_revision. Passed in the repo name and a string of PR ids
    # that are then used to find the repo_id, PR id array. The user_id is found through one of the pull requests.
    #
    # Returns - nothing, but makes a new deploy
    def create
      if params[:git_revision].nil? || params[:repo_name].nil? || params[:pull_request_ids].nil?
        render text: "Missing a necessary parameter: git revision, pull request ids, or repository name.", :status => 400 and return
      else
        @deploy = Deploy.new
        @deploy.deployed_at = params[:deployed_at]
        @deploy.git_revision = params[:git_revision]
        @repo = Hubstats::Repo.where(full_name: params[:repo_name])

        if !valid_repo(@repo)
          render text: "Repository name is invalid.", :status => 400 and return
        else
          @deploy.repo_id = @repo.first.id.to_i
        end

        pull_request_id_array = params[:pull_request_ids].split(",").map {|i| i.strip.to_i}
        if !valid_pr_ids(pull_request_id_array)
          render text: "No pull request ids given.", :status => 400 and return
        else
          @deploy.pull_requests = Hubstats::PullRequest.where(repo_id: @deploy.repo_id).where(number: pull_request_id_array)
        end

        if !valid_pulls
          render text: "Pull requests not valid", :status => 400 and return
        end

        if @deploy.save
          render :nothing => true, :status => 200 and return
        else
          render :nothing => true, :status => 400 and return
        end
      end
    end

    # Public - Checks if the repo that's passed in is empty.
    #
    # repo - the repository
    #
    # Returns - true if the repo is valid 
    def valid_repo(repo)
      return !repo.empty?
    end

    # Public - Checks if the array is empty or if the ids in the array are invalid.
    #
    # pull_id_array - the array of pull request ids
    #
    # Returns - returns true if the array neither is empty nor comes out to [0]
    def valid_pr_ids(pull_id_array)
      return !pull_id_array.empty? && pull_id_array != [0]
    end

    # Public - Checks if the first pull assigned to the new deploy is nil, if the merged_by part is nil. If nothing is
    # nil, it will set the user_id of the deploy to be the merged_by of the pull.
    #
    # Returns - true and changes the user_id of deploy, else returns false
    def valid_pulls
      pull = @deploy.pull_requests.first
      return false if pull.nil? || pull.merged_by.nil?
      @deploy.user_id = pull.merged_by
      return true
    end
  end
 end
