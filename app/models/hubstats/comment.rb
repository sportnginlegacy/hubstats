module Hubstats
  class Comment < ActiveRecord::Base
    scope :pull_reviews_count, lambda {
      select("hubstats_comments.user_id")
      .select("COUNT(DISTINCT hubstats_pull_requests.id) as total")
      .joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.id = hubstats_comments.pull_request_id")
      .where("hubstats_pull_requests.user_id != hubstats_comments.user_id")
      .group("hubstats_comments.user_id")
    }

    scope :created_since, lambda {|time| where("created_at > ?", time) }
    scope :belonging_to_pull_request, lambda {|pull_request_id| where(pull_request_id: pull_request_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}
    scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}

    attr_accessible :id, :html_url, :url, :pull_request_url, :diff_hunk, :path,
      :position, :original_position, :line, :commit_id, :original_commit_id,
      :body, :created_at, :updated_at, :user_id, :pull_request_id, :repo_id
  
    belongs_to :user
    belongs_to :pull_request
    belongs_to :repo
    
    def self.find_or_create_comment(github_comment)
      github_comment = github_comment.to_h if github_comment.respond_to? :to_h
      
      user = Hubstats::User.find_or_create_user(github_comment[:user])
      pull_request = Hubstats::PullRequest.where({url: github_comment[:pull_request_url]}).first
      
      if pull_request
        comment_data = github_comment.slice(*Hubstats::Comment.column_names.map(&:to_sym))
        comment_data[:user_id] = user.id
        comment_data[:pull_request_id] = pull_request.id
        comment_data[:repo_id] = pull_request.repo_id

        comment = where(:id => comment_data[:id]).first_or_create(comment_data)
        return comment if comment.save
        Rails.logger.debug comment.errors.inspect
      end
    end

    def self.find_or_create_issue_comment(github_comment,github_repo)
      github_comment = github_comment.to_h if github_comment.respond_to? :to_h
        
      repo = Hubstats::Repo.where(full_name: github_repo).first
      user = Hubstats::User.find_or_create_user(github_comment[:user])
      pull_request = Hubstats::PullRequest.belonging_to_repo(repo.id).where({number: github_comment[:number]}).first
      
      if pull_request 
        comment_data = github_comment.slice(*Hubstats::Comment.column_names.map(&:to_sym))
        comment_data[:user_id] = user.id
        comment_data[:pull_request_id] = pull_request.id
        comment_data[:repo_id] = pull_request.repo_id

        comment = where(:id => comment_data[:id]).first_or_create(comment_data)
        return comment if comment.save
        Rails.logger.debug comment.errors.inspect
      end
    end
  end
end

def get_issue_number(issue_url)
  issue_url.split('/')[-1]
end