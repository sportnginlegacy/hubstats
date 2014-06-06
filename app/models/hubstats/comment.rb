module Hubstats
  class Comment < ActiveRecord::Base
    attr_accessible :id, :html_url, :url, :pull_request_url, :diff_hunk, :path, :position, :original_position, :line, :commit_id, :original_commit_id, :body, :created_at, :updated_at
  
    belongs_to :user
    
  end
end
