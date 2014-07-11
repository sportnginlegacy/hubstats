module Hubstats
  class User < ActiveRecord::Base

    scope :pull_requests_count, lambda { |time|
      select("hubstats_users.id as user_id")
      .select("COUNT(DISTINCT hubstats_pull_requests.id) AS pull_request_count")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.user_id = hubstats_users.id AND hubstats_pull_requests.closed_at > '#{time}'")
      .group("hubstats_users.id")
    }
    scope :pull_requests_count_by_repo, lambda { |time,repo_id|
      select("hubstats_users.id as user_id")
      .select("COUNT(DISTINCT hubstats_pull_requests.id) AS pull_request_count")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.user_id = hubstats_users.id AND hubstats_pull_requests.closed_at > '#{time}' AND hubstats_pull_requests.repo_id = '#{repo_id}'")
      .group("hubstats_users.id")
    }
    scope :comments_count, lambda { |time|
      select("hubstats_users.id as user_id")
      .select("COUNT(DISTINCT hubstats_comments.id) AS comment_count")
      .joins("LEFT JOIN hubstats_comments ON hubstats_comments.user_id = hubstats_users.id AND hubstats_comments.created_at > '#{time}'")
      .group("hubstats_users.id")
    }
    scope :comments_count_by_repo, lambda { |time,repo_id|
      select("hubstats_users.id as user_id")
      .select("COUNT(DISTINCT hubstats_comments.id) AS comment_count")
      .joins("LEFT JOIN hubstats_comments ON hubstats_comments.user_id = hubstats_users.id AND hubstats_comments.created_at > '#{time}' AND hubstats_comments.repo_id = '#{repo_id}'")
      .group("hubstats_users.id")
    }
    scope :pulls_reviewed_count, lambda { |time|
      select("hubstats_users.id as user_id")
      .select("COUNT(DISTINCT hubstats_pull_requests.id) as reviews_count")
      .joins("LEFT JOIN hubstats_comments ON hubstats_comments.user_id = hubstats_users.id AND hubstats_comments.created_at > '#{time}'")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.id = hubstats_comments.pull_request_id AND hubstats_pull_requests.closed_at > '#{time}'")
      .where("hubstats_pull_requests.user_id != hubstats_users.id")
      .group("hubstats_users.id")
    }

    scope :pull_and_comment_count, lambda { |time|
      select("hubstats_users.*, pull_request_count, comment_count")
      .joins("LEFT JOIN (#{pull_requests_count(time).to_sql}) AS pull_requests ON pull_requests.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{comments_count(time).to_sql}) AS comments ON comments.user_id = hubstats_users.id")
      .group("hubstats_users.id")
    }

    scope :pull_and_comment_count_by_repo, lambda { |time,repo_id|
            select("hubstats_users.*, pull_request_count, comment_count")
      .joins("LEFT JOIN (#{pull_requests_count_by_repo(time,repo_id).to_sql}) AS pull_requests ON pull_requests.user_id = hubstats_users.id")
      .joins("LEFT JOIN (#{comments_count_by_repo(time,repo_id).to_sql}) AS comments ON comments.user_id = hubstats_users.id")
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

    def self.create_or_update(github_user)
      github_user[:role] = github_user.delete :type  ##changing :type in to :role
      github_user = github_user.to_h.with_indifferent_access unless github_user.is_a? Hash

      user_data = github_user.slice(*Hubstats::User.column_names.map(&:to_sym))
      
      user = Hubstats::User.where(:id => user_data[:id]).first_or_create(user_data)
      return user if user.update_attributes(user_data)
      Rails.logger.warn user.errors.inspect
    end

    def self.with_pulls_or_comments(time, repo_id = nil)
      if repo_id
        pull_and_comment_count_by_repo(time,repo_id).weighted_sort
      else
        pull_and_comment_count(time).weighted_sort
      end
    end

    def to_param
      self.login
    end
  end
end
