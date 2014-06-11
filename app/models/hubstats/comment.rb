module Hubstats
  class Comment < ActiveRecord::Base
    attr_accessible :id, :html_url, :url, :pull_request_url, :diff_hunk, :path,
      :position, :original_position, :line, :commit_id, :original_commit_id,
      :body, :created_at, :updated_at, :user_id
  
    belongs_to :user
    
    def self.find_or_create_comment(github_comment)
      github_comment = github_comment.to_h if github_comment.respond_to? :to_h
      
      user = Hubstats::User.find_or_create_user(github_comment[:user])
      comment_data = github_comment.slice(*Hubstats::Comment.column_names.map(&:to_sym))
      comment_data[:user_id] = user.id

      comment = where(:id => comment_data[:id]).first_or_create(comment_data)
      return comment if comment.save
      Rails.logger.debug comment.errors.inspect
    end

  end
end
