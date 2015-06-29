module Hubstats
  class User < ActiveRecord::Base

    # Various checks that can be used to filter and find info about users.
    scope :with_id, lambda {|user_id| where(id: user_id.split(',')) if user_id}
    scope :only_active, having("comment_count > 0 OR pull_request_count > 0")
    scope :with_contributions, lambda {|repo_id| pull_and_comment_count_by_repo(@start_date, @end_date, repo_id.split(',')) if repo_id}

    # Public - Counts all of the deploys for selected repo that occurred between the start_date and end_date.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - count of deploys
    scope :deploys_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
       .select("IFNULL(COUNT(DISTINCT hubstats_deploys.id),0) AS deploy_count")
       .joins(sanitize_sql_array(["LEFT JOIN hubstats_deploys ON hubstats_deploys.user_id = hubstats_users.id AND (hubstats_deploys.deployed_at BETWEEN ? AND ?)", start_date, end_date]))
       .group("hubstats_users.id")
    }

    # Public - Counts all of the comments for selected repo that occurred between the start_date and end_date.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - count of comments
    scope :comments_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
       .select("IFNULL(COUNT(DISTINCT hubstats_comments.id),0) AS comment_count")
       .joins(sanitize_sql_array(["LEFT JOIN hubstats_comments ON hubstats_comments.user_id = hubstats_users.id AND (hubstats_comments.created_at BETWEEN ? AND ?)", start_date, end_date]))
       .group("hubstats_users.id")
    }
 
    # Public - Counts all of the merged pull requests for selected repo that occurred between the start_date and end_date.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - count of pull requests
    scope :pull_requests_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
      .select("IFNULL(COUNT(DISTINCT hubstats_pull_requests.id),0) AS pull_request_count")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.user_id = hubstats_users.id AND (hubstats_pull_requests.merged_at BETWEEN ? AND ?) AND hubstats_pull_requests.merged = '1'", start_date, end_date]))
      .group("hubstats_users.id")
    }

    # pull_and_comment_count
    # params: start_date, end_date
    # Counts all of the merged pull requests and comments that occurred between the start_date and end_date.
    scope :pull_and_comment_count, lambda {|start_date, end_date|
      select("hubstats_users.*, pull_request_count, comment_count")
      .joins("LEFT JOIN (#{pull_requests_count(start_date, end_date).to_sql}) AS pull_requests ON pull_requests.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{comments_count(start_date, end_date).to_sql}) AS comments ON comments.user_id = hubstats_users.id")
      .group("hubstats_users.id")
    }

    # comments_count_by_repo
    # params: start_date, end_date, repo_id
    # Counts all commetns that belong to a specific repository that have been created between the start_date and end_date for
    # a selected user.
    scope :comments_count_by_repo, lambda {|start_date, end_date, repo_id|
      select("hubstats_users.id as user_id")
      .select("COUNT(DISTINCT hubstats_comments.id) AS comment_count")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_comments ON hubstats_comments.user_id = hubstats_users.id AND (hubstats_comments.created_at BETWEEN ? AND ?) AND hubstats_comments.repo_id = ?", start_date, end_date, repo_id]))
      .group("hubstats_users.id")
    }

    # pull_requests_count_by_repo
    # params: start_date, end_date, repo_id
    # Counts all of the merged pull requests that belong to a specific repository that have been merged between the start_date
    # and end_date. All pull requests must also belong to the selected user.
    scope :pull_requests_count_by_repo, lambda {|start_date, end_date, repo_id|
      select("hubstats_users.id as user_id")
      .select("IFNULL(COUNT(DISTINCT hubstats_pull_requests.id),0) AS pull_request_count")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.user_id = hubstats_users.id AND (hubstats_pull_requests.merged_at BETWEEN ? AND ?) AND hubstats_pull_requests.repo_id = ? AND hubstats_pull_requests.merged = '1'", start_date, end_date, repo_id]))
      .group("hubstats_users.id")
    }

    # pull_and_comment_count_by_repo
    # params: start_date, end_date, repo_id
    # Counts all of the merged pull requests and comments that belong to a repository and occurred between the start_date and end_date.
    scope :pull_and_comment_count_by_repo, lambda {|start_date, end_date, repo_id|
      select("hubstats_users.*, pull_request_count, comment_count")
      .joins("LEFT JOIN (#{pull_requests_count_by_repo(start_date, end_date, repo_id).to_sql}) AS pull_requests ON pull_requests.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{comments_count_by_repo(start_date, end_date, repo_id).to_sql}) AS comments ON comments.user_id = hubstats_users.id")
      .group("hubstats_users.id")
    }
    
    # Public - Counts all of the addtiions and deletions made from PRs by the selected user that have been merged between the start_date
    # and the end_date.
    #
    # start_date - the start of the date range
    # end_date - the end of the data range
    #
    # Returns - the additions and deletions
    scope :net_additions_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
      .select("SUM(IFNULL(hubstats_pull_requests.additions, 0)) AS additions")
      .select("SUM(IFNULL(hubstats_pull_requests.deletions, 0)) AS deletions")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.user_id = hubstats_users.id AND (hubstats_pull_requests.created_at BETWEEN ? AND ?) AND hubstats_pull_requests.merged = '1'", start_date, end_date]))
      .group("hubstats_users.id")
    }

    # Public - Joins all of the metrics together for selected repository: average additions and deletions, comments, pull requests, and deploys.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - all of the stats about the repo
    scope :with_all_metrics, lambda {|start_date, end_date|
      select("hubstats_users.*, deploy_count, pull_request_count, comment_count, additions, deletions")
      .joins("LEFT JOIN (#{net_additions_count(start_date, end_date).to_sql}) AS net_additions ON net_additions.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{pull_requests_count(start_date, end_date).to_sql}) AS pull_requests ON pull_requests.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{comments_count(start_date, end_date).to_sql}) AS comments ON comments.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{deploys_count(start_date, end_date).to_sql}) AS deploys ON deploys.user_id = hubstats_users.id")
      .group("hubstats_users.id")
    }

    attr_accessible :login, :id, :avatar_url, :gravatar_id, :url, :html_url, :followers_url,
      :following_url, :gists_url, :starred_url, :subscriptions_url, :organizations_url,
      :repos_url, :events_url, :received_events_url, :role, :site_admin
    
    validates :id, presence: true, uniqueness: true

    has_many :comments
    has_many :repos, :class_name => "Repo"
    has_many :pull_requests
    has_many :deploys

    # Public - Creates a new user form a GitHub webhook.
    #
    # github_user - the info from Github about the new or updated user
    #
    # Returns - the user 
    def self.create_or_update(github_user)
      github_user[:role] = github_user.delete :type  ##changing :type in to :role
      github_user = github_user.to_h.with_indifferent_access unless github_user.is_a? Hash

      user_data = github_user.slice(*Hubstats::User.column_names.map(&:to_sym))
      
      user = Hubstats::User.where(:id => user_data[:id]).first_or_create(user_data)
      return user if user.update_attributes(user_data)
      Rails.logger.warn user.errors.inspect
    end

    # Public - If a repo_id is provided, will sort the users based on the number of comments and pull requests on that repo 
    # within the start_date and end_date. If no repo_id is provided, will still sort, just considering all PRs and comments 
    # within the two dates.
    #
    # start_date - the start of the date range
    # end_date - the end of the data range
    # repo_id - the id of the repository (optional)
    #
    # Returns - the count of data that fulfills the sql queries 
    def self.with_pulls_or_comments(start_date, end_date, repo_id = nil)
      if repo_id
        pull_and_comment_count_by_repo(start_date, end_date, repo_id)
      else
        pull_and_comment_count(start_date, end_date)
      end
    end

    # Public - Designed so that the list of users can be ordered based on deploys, pulls, comments, net additions, or name.
    # if none of these are selected, then the default is to order by pull request count in descending order.
    #
    # order_params - the param of what the users should be sorted by
    #
    # Returns - the user data ordered
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
        when 'netadditions'
          order("additions - deletions #{order}")
        when 'name'
          order("login #{order}")
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
      self.login
    end
  end
end
