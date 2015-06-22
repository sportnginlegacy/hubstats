module Hubstats
  class User < ActiveRecord::Base

    scope :with_id, lambda {|user_id| where(id: user_id.split(',')) if user_id}

    scope :deploys_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
       .select("IFNULL(COUNT(DISTINCT hubstats_deploys.id),0) AS deploy_count")
       .joins("LEFT JOIN hubstats_deploys ON hubstats_deploys.user_id = hubstats_users.id AND (hubstats_deploys.deployed_at BETWEEN '#{start_date}' AND '#{end_date}')")
       .group("hubstats_users.id")
    }

    scope :comments_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
       .select("IFNULL(COUNT(DISTINCT hubstats_comments.id),0) AS comment_count")
       .joins("LEFT JOIN hubstats_comments ON hubstats_comments.user_id = hubstats_users.id AND (hubstats_comments.created_at BETWEEN '#{start_date}' AND '#{end_date}')")
       .group("hubstats_users.id")
    }
 
    scope :pull_requests_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
      .select("IFNULL(COUNT(DISTINCT hubstats_pull_requests.id),0) AS pull_request_count")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.user_id = hubstats_users.id AND (hubstats_pull_requests.merged_at BETWEEN '#{start_date}' AND '#{end_date}') AND hubstats_pull_requests.merged = '1'")
      .group("hubstats_users.id")
    }

    scope :pull_requests_count_by_repo, lambda {|start_date, end_date,repo_id|
      select("hubstats_users.id as user_id")
      .select("IFNULL(COUNT(DISTINCT hubstats_pull_requests.id),0) AS pull_request_count")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.user_id = hubstats_users.id AND (hubstats_pull_requests.created_at BETWEEN '#{start_date}' AND '#{end_date}') AND hubstats_pull_requests.repo_id = '#{repo_id}' AND hubstats_pull_requests.merged = '1'")
      .group("hubstats_users.id")
    }

    scope :comments_count_by_repo, lambda {|start_date, end_date, repo_id|
      select("hubstats_users.id as user_id")
      .select("COUNT(DISTINCT hubstats_comments.id) AS comment_count")
      .joins("LEFT JOIN hubstats_comments ON hubstats_comments.user_id = hubstats_users.id AND (hubstats_comments.created_at BETWEEN'#{start_date}' AND '#{end_date}') AND hubstats_comments.repo_id = '#{repo_id}'")
      .group("hubstats_users.id")
    }

    scope :pulls_reviewed_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
      .select("COUNT(DISTINCT hubstats_pull_requests.id) as reviews_count")
      .joins("LEFT JOIN hubstats_comments ON hubstats_comments.user_id = hubstats_users.id AND (hubstats_comments.created_at BETWEEN '#{start_date}' AND '#{end_date}')")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.id = hubstats_comments.pull_request_id AND (hubstats_pull_requests.closed_at BETWEEN '#{start_date}' AND '#{end_date}')")
      .where("hubstats_pull_requests.user_id != hubstats_users.id")
      .group("hubstats_users.id")
    }
    
    scope :net_additions_count, lambda {|start_date, end_date|
      select("hubstats_users.id as user_id")
      .select("SUM(IFNULL(hubstats_pull_requests.additions, 0)) AS additions")
      .select("SUM(IFNULL(hubstats_pull_requests.deletions, 0)) AS deletions")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.user_id = hubstats_users.id AND (hubstats_pull_requests.created_at BETWEEN '#{start_date}' AND '#{end_date}') AND hubstats_pull_requests.merged = '1'")
      .group("hubstats_users.id")
    }

    scope :pull_and_comment_count, lambda {|start_date, end_date|
      select("hubstats_users.*, pull_request_count, comment_count")
      .joins("LEFT JOIN (#{pull_requests_count(start_date, end_date).to_sql}) AS pull_requests ON pull_requests.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{comments_count(start_date, end_date).to_sql}) AS comments ON comments.user_id = hubstats_users.id")
      .group("hubstats_users.id")
    }

    scope :pull_and_comment_count_by_repo, lambda {|start_date, end_date, repo_id|
      select("hubstats_users.*, pull_request_count, comment_count")
      .joins("LEFT JOIN (#{pull_requests_count_by_repo(start_date, end_date, repo_id).to_sql}) AS pull_requests ON pull_requests.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{comments_count_by_repo(start_date, end_date, repo_id).to_sql}) AS comments ON comments.user_id = hubstats_users.id")
      .group("hubstats_users.id")
    }

    scope :with_all_metrics, lambda {|start_date, end_date|
      select("hubstats_users.*, deploy_count, pull_request_count, comment_count, additions, deletions")
      .joins("LEFT JOIN (#{net_additions_count(start_date, end_date).to_sql}) AS net_additions ON net_additions.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{pull_requests_count(start_date, end_date).to_sql}) AS pull_requests ON pull_requests.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{comments_count(start_date, end_date).to_sql}) AS comments ON comments.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{deploys_count(start_date, end_date).to_sql}) AS deploys ON deploys.user_id = hubstats_users.id")
      .group("hubstats_users.id")
    }

    scope :only_active, having("comment_count > 0 OR pull_request_count > 0")
    scope :weighted_sort, order("(pull_request_count)*2 + (comment_count) DESC")

    attr_accessible :login, :id, :avatar_url, :gravatar_id, :url, :html_url, :followers_url,
      :following_url, :gists_url, :starred_url, :subscriptions_url, :organizations_url,
      :repos_url, :events_url, :received_events_url, :role, :site_admin
    
    validates :id, presence: true, uniqueness: true

    has_many :comments
    has_many :repos, :class_name => "Repo"
    has_many :pull_requests
    has_many :deploys

    def self.create_or_update(github_user)
      github_user[:role] = github_user.delete :type  ##changing :type in to :role
      github_user = github_user.to_h.with_indifferent_access unless github_user.is_a? Hash

      user_data = github_user.slice(*Hubstats::User.column_names.map(&:to_sym))
      
      user = Hubstats::User.where(:id => user_data[:id]).first_or_create(user_data)
      return user if user.update_attributes(user_data)
      Rails.logger.warn user.errors.inspect
    end

    def self.with_pulls_or_comments(start_date, end_date, repo_id = nil)
      if repo_id
        pull_and_comment_count_by_repo(start_date, end_date, repo_id).weighted_sort
      else
        pull_and_comment_count(start_date, end_date).weighted_sort
      end
    end

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

    def to_param
      self.login
    end
  end
end
