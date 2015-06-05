require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < ApplicationController

    def index
      # sets to include user and repo, and sorts data
      @deploys = Hubstats::Deploy.includes(:repo).includes(:pull_requests)
        .belonging_to_users(params[:users]).belonging_to_repos(params[:repos])
        .group_by(params[:group])
        .order_with_timespan(@timespan, params[:order])
        .paginate(:page => params[:page], :per_page => 15)

      # enables grouping by user or repo
      if params[:group] == "user"
        @groups = @deploys.to_a.group_by(&:user_name)
      elsif params[:group] == "repo"
        @groups = @deploys.to_a.group_by(&:repo_name)
      end
    end

    # show basic stats and pull requests from a single deploy
    def show
      @deploy = Hubstats::Deploy.includes(:repo).includes(:pull_requests).find(params[:id])
      repo = @deploy.repo
      @pull_requests = @deploy.pull_requests
      pull_request_count = @pull_requests.length
      net_additions = find_net_additions(@deploy.id)
      comment_count = find_comment_count(@deploy.id)
      @stats = {
        pull_count: pull_request_count,
        net_additions: net_additions,
        comment_count: comment_count
      }
    end

    # finds all of the additions and deletions in all pull requests and then makes the net additions
    def find_net_additions(deploy_id)
      deploy = Hubstats::Deploy.find(deploy_id)
      pull_requests = deploy.pull_requests
      total_additions = 0
      total_deletions = 0
      pull_requests.each do |pull|
        total_additions += pull.additions.to_i
        total_deletions += pull.deletions.to_i
      end
      return total_additions - total_deletions
    end

    # returns the total amount of comments from all pull requests in a deploy
    def find_comment_count(deploy_id)
      deploy = Hubstats::Deploy.find(deploy_id)
      pull_requests = deploy.pull_requests
      total_comments = 0
      pull_requests.each do |pull|
        if pull.comments
          total_comments += Hubstats::Comment.belonging_to_pull_request(pull.id).includes(:user).created_since(@timespan).count(:all)
        end
      end
      return total_comments
    end

    # make a new deploy with all of the correct attributes
    def create
      if params[:deployed_by].nil? || params[:git_revision].nil? || params[:repo_name].nil?
        render text: "Missing a necessary parameter: deployer, git revision, or repository name.", :status => 400 and return
      else
        @deploy = Deploy.new
        @deploy.deployed_at = params[:deployed_at]
        @deploy.deployed_by = params[:deployed_by]
        @deploy.git_revision = params[:git_revision]
        @repo = Hubstats::Repo.where(full_name: params[:repo_name])
        
        if @repo.empty?
          render text: "Repository name is invalid.", :status => 400 and return
        else
          @deploy.repo_id = @repo.first.id.to_i
        end

        @pull_request_id_array = params[:pull_request_ids].split(",").map {|i| i.strip.to_i}
        @deploy.pull_requests = Hubstats::PullRequest.where(repo_id: @deploy.repo_id)
                                                     .where(number: @pull_request_id_array)

        if @deploy.save
          render :nothing =>true, :status => 200 and return
        else
          render :nothing => true, :status => 400 and return
        end
      end
    end
  end
 end
