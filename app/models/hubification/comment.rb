module Hubification
  class Comment < ActiveRecord::Base
    attr_accessible :html_url, :url, :id, :body, :path, 
      :position, :line, :commit_id, :created_at, :updated_at
      
    belongs_to :user
    
  end
end
