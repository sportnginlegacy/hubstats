require_dependency "hubstats/application_controller"

module Hubstats
  class DeploysController < ApplicationController

    def index
      #deploy_id = Hubstats::Deploy
      #  .belonging_to_repos(params[:repo])
      #  .belonging_to_users(params[:users])
      #  .order_with_timespan(@timespan, "ASC")
      #  .map(&:id)

      # sets to include user and repo, and sorts data
      @deploys = Hubstats::Deploy
        .belonging_to_users(params[:users]).belonging_to_repos(params[:repos])
        .order_with_timespan(@timespan, params[:order])
        .group_by(params[:group])
        .paginate(:page => params[:page], :per_page => 15)

      # enables grouping by user or repo
      if params[:group] == "user"
        @groups = @deploys.to_a.group_by(&:user_name)
      elsif params[:group] == "repo"
        @groups = @deploys.to_a.group_by(&:repo_name)
      else
        @groups = nil
      end
    end

    def show
      @deploy = Hubstats::Deploy.find(params[:id])
      @repo = @deploy.repo
      @pull_requests = @deploy.pull_requests
      @pull_request_count = @pull_requests.length
      @net_additions = find_net_additions(@deploy.id)
      @comment_count = find_comment_count(@deploy.id)
      @stats = {
        pull_count: @pull_request_count,
        net_additions: @net_additions,
        comment_count: @comment_count
      }
    end

    def find_net_additions(deploy_id)
      @deploy = Hubstats::Deploy.find(deploy_id)
      @pull_requests = @deploy.pull_requests
      @total_additions = 0
      @total_deletions = 0
      @pull_requests.each do |pull|
        @total_additions += pull.additions.to_i
        @total_deletions += pull.deletions.to_i
      end
      return @total_additions - @total_deletions
    end

    def find_comment_count(deploy_id)
      @deploy = Hubstats::Deploy.find(deploy_id)
      @pull_requests = @deploy.pull_requests
      @total_comments = 0
      @pull_requests.each do |pull|
        if pull.comments
          @total_comments += pull.comments
        end
      end
      return @total_comments
    end

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
