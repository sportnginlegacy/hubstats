module Hubstats
  class Repo < ActiveRecord::Base

    # Various checks that can be used to filter and find info about repos.
    scope :with_recent_activity, lambda {|start_date, end_date| where("hubstats_repos.updated_at BETWEEN ? AND ?", start_date, end_date).order("updated_at DESC")}
    scope :with_id, lambda {|repo_id| where(id: repo_id.split(',')) if repo_id}

    # Public - Counts all of the deploys for selected repo that occurred between the start_date and end_date.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - count of deploys
    scope :deploys_count, lambda {|start_date, end_date|
      select("hubstats_repos.id as repo_id")
       .select("IFNULL(COUNT(DISTINCT hubstats_deploys.id),0) AS deploy_count")
       .joins(sanitize_sql_array(["LEFT JOIN hubstats_deploys ON hubstats_deploys.repo_id = hubstats_repos.id AND (hubstats_deploys.deployed_at BETWEEN ? AND ?)", start_date, end_date]))
       .group("hubstats_repos.id")
    }

    # Public - Counts all of the comments for selected repo that occurred between the start_date and end_date.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - count of comments
    scope :comments_count, lambda {|start_date, end_date|
      select("hubstats_repos.id as repo_id")
       .select("IFNULL(COUNT(DISTINCT hubstats_comments.id),0) AS comment_count")
       .joins(sanitize_sql_array(["LEFT JOIN hubstats_comments ON hubstats_comments.repo_id = hubstats_repos.id AND (hubstats_comments.created_at BETWEEN ? AND ?)", start_date, end_date]))
       .group("hubstats_repos.id")
    }
 
    # Public - Counts all of the merged pull requests for selected repo that occurred between the start_date and end_date.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - count of pull requests
    scope :pull_requests_count, lambda {|start_date, end_date|
      select("hubstats_repos.id as repo_id")
      .select("IFNULL(COUNT(DISTINCT hubstats_pull_requests.id),0) AS pull_request_count")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.repo_id = hubstats_repos.id AND (hubstats_pull_requests.merged_at BETWEEN ? AND ?) AND hubstats_pull_requests.merged = '1'", start_date, end_date]))
      .group("hubstats_repos.id")
    }

    # Public - Averages all of the additions and deletions of the merged PRs for selected repo.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - the average additions and deletions
    scope :averages, lambda {|start_date, end_date|
      select("hubstats_repos.id as repo_id")
      .select("ROUND(IFNULL(AVG(hubstats_pull_requests.additions),0)) AS average_additions")
      .select("ROUND(IFNULL(AVG(hubstats_pull_requests.deletions),0)) AS average_deletions")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.repo_id = hubstats_repos.id AND hubstats_pull_requests.merged = '1' AND (hubstats_pull_requests.merged_at BETWEEN ? AND ?)", start_date, end_date]))
      .group("hubstats_repos.id")
    }

    # Public - Joins all of the metrics together for selected repository: average additions and deletions, comments, pull requests, and deploys.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - all of the stats about the repo
    scope :with_all_metrics, lambda {|start_date, end_date|
      select("hubstats_repos.*, deploy_count, pull_request_count, comment_count, average_additions, average_deletions")
      .joins("LEFT JOIN (#{averages(start_date, end_date).to_sql}) AS averages ON averages.repo_id = hubstats_repos.id")
      .joins("LEFT JOIN (#{pull_requests_count(start_date, end_date).to_sql}) AS pull_requests ON pull_requests.repo_id = hubstats_repos.id")
      .joins("LEFT JOIN (#{comments_count(start_date, end_date).to_sql}) AS comments ON comments.repo_id = hubstats_repos.id")
      .joins("LEFT JOIN (#{deploys_count(start_date, end_date).to_sql}) AS deploys ON deploys.repo_id = hubstats_repos.id")
      .group("hubstats_repos.id")
    }

    attr_accessible :id, :name, :full_name, :homepage, :language, :description, :default_branch,
      :url, :html_url, :clone_url, :git_url, :ssh_url, :svn_url, :mirror_url,
      :hooks_url, :issue_events_url, :events_url, :contributors_url, :git_commits_url, 
      :issue_comment_url, :merges_url, :issues_url, :pulls_url, :labels_url,
      :forks_count, :stargazers_count, :watchers_count, :size, :open_issues_count,
      :has_issues, :has_wiki, :has_downloads,:fork, :private, 
      :pushed_at, :created_at, :updated_at, :owner_id

    has_many :pull_requests
    has_many :deploys
    has_many :comments
    belongs_to :owner, :class_name => "User", :foreign_key => "id"

    # Public - Makes a new repository based on a GitHub webhook. Sets a user (owner) based on users that are already in the database.
    #
    # github_repo - the info about the new or updated repository
    #
    # Returns - the repository
    def self.create_or_update(github_repo)
      github_repo = github_repo.to_h.with_indifferent_access if github_repo.respond_to? :to_h
      repo_data = github_repo.slice(*column_names.map(&:to_sym))

      if github_repo[:owner]
        user = Hubstats::User.create_or_update(github_repo[:owner])
        repo_data[:owner_id] = user[:id]
      end

      repo = where(:id => repo_data[:id]).first_or_create(repo_data)
      return repo if repo.update_attributes(repo_data)
      Rails.logger.warn repo.errors.inspect
    end

    # Public - Designed so that the list of repositories can be ordered based on deploys, pulls, comments, additions, deletions, or name.
    # if none of these are selected, then the default is to order by pull request count in descending order.
    #
    # order_params - the param of what the repos should be sorted by
    #
    # Returns - the repo data ordered
    def self.custom_order(order_params)
      if order_params
        order = order_params.include?('asc') ? "ASC" : "DESC"
        case order_params.split('-').first
        when 'deploys'
          order("deploy_count #{order}")
        when 'pulls'
          order("pull_request_count #{order}")
        when 'comments'
          order("comment_count #{order}")
        when 'additions'
          order("average_additions #{order}")
        when 'deletions'
          order("average_deletions #{order}")
        when 'name'
          order("name #{order}")
        else
          order("pull_request_count #{order}")
        end
      else 
        order("pull_request_count DESC")
      end
    end
    
    # Public - Designed to make a path for the show page when a repository is selected.
    #
    # Returns - the show page of self.name
    def to_param
      self.name
    end

  end
end
