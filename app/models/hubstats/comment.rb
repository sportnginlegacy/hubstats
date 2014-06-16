module Hubstats
  class Comment < ActiveRecord::Base
    scope :created_since, lambda {|time| where("created_at > ?", time).order("closed_at DESC") }
    scope :belonging_to_pull_request, lambda {|pull_request_id| where(pull_request_id: pull_request_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}

    attr_accessible :id, :html_url, :url, :pull_request_url, :diff_hunk, :path,
      :position, :original_position, :line, :commit_id, :original_commit_id,
      :body, :created_at, :updated_at, :user_id, :pull_request_id
  
    belongs_to :user
    belongs_to :pull_request
    
    def self.find_or_create_comment(github_comment)
      github_comment = github_comment.to_h if github_comment.respond_to? :to_h
      
      user = Hubstats::User.find_or_create_user(github_comment[:user])
      pull_request = Hubstats::PullRequest.where({url: github_comment[:pull_request_url]}).first
      
      comment_data = github_comment.slice(*Hubstats::Comment.column_names.map(&:to_sym))
      comment_data[:user_id] = user.id
      comment_data[:pull_request_id] = pull_request.id

      comment = where(:id => comment_data[:id]).first_or_create(comment_data)
      return comment if comment.save
      Rails.logger.debug comment.errors.inspect
    end

  end
end
