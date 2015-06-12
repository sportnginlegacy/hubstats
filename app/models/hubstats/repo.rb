module Hubstats
  class Repo < ActiveRecord::Base

    scope :with_recent_activity, lambda {|time| where("created_at > ?", time).order("updated_at DESC")}
    scope :with_id, lambda {|user_id| where(id: user_id.split(',')) if user_id}

    scope :deploys_or_pull_requests_or_comments_count, lambda {|time, data, began_time, name|
      select("hubstats_repos.id as repo_id")
       .select("IFNULL(COUNT(DISTINCT #{data}.id),0) AS #{name}_count")
       .joins("LEFT JOIN #{data} ON #{data}.repo_id = hubstats_repos.id AND #{data}.#{began_time} > '#{time}'")
       .group("hubstats_repos.id")
    }

    scope :deploys_count, lambda {|time|
      deploys_or_pull_requests_or_comments_count(time, "hubstats_deploys", "deployed_at", "deploy")
    }

    scope :comments_count, lambda {|time|
      deploys_or_pull_requests_or_comments_count(time, "hubstats_comments", "created_at", "comment")
    }
 
    scope :pull_requests_count, lambda{|time|
      deploys_or_pull_requests_or_comments_count(time, "hubstats_pull_requests", "created_at", "pull_request")
    }

    scope :averages, lambda { |time|
      select("hubstats_repos.id as repo_id")
      .select("ROUND(IFNULL(AVG(hubstats_pull_requests.additions),0)) AS average_additions")
      .select("ROUND(IFNULL(AVG(hubstats_pull_requests.deletions),0)) AS average_deletions")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.repo_id = hubstats_repos.id AND hubstats_pull_requests.merged = '1'")
      .group("hubstats_repos.id")
    }

    scope :with_all_metrics, lambda { |time|
      select("hubstats_repos.*, deploy_count, pull_request_count, comment_count, average_additions, average_deletions")
      .joins("LEFT JOIN (#{averages(time).to_sql}) AS averages ON averages.repo_id = hubstats_repos.id")
      .joins("LEFT JOIN (#{pull_requests_count(time).to_sql}) AS pull_requests ON pull_requests.repo_id = hubstats_repos.id")
      .joins("LEFT JOIN (#{comments_count(time).to_sql}) AS comments ON comments.repo_id = hubstats_repos.id")
      .joins("LEFT JOIN (#{deploys_count(time).to_sql}) AS deploys ON deploys.repo_id = hubstats_repos.id")
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
    belongs_to :owner, :class_name => "User", :foreign_key => "id"

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
        else
          order("pull_request_count #{order}")
        end
      else 
        order("pull_request_count DESC")
      end
    end
    
    def to_param
      self.name
    end

  end
end
