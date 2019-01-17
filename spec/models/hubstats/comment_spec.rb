require 'spec_helper'

module Hubstats
  describe Comment, :type => :model do
    it 'should create and return a comment and user' do
      repo = create(:repo, :created_at => Date.today, :updated_at => Date.today)
      user = create(:user, :created_at => Date.today, :updated_at => Date.today,
                   :login => "elliothursh", :id => 10)
      comment = create(:comment, :created_at => Date.today, :updated_at => Date.today,
                      :user => user, :pull_request_url => "www.pull.com", :id => 100, :repo => repo)
      pull_request = create(:pull_request, :created_at => Date.today, :updated_at => Date.today,
                           :id => 1000, :url => "www.pull.com", :repo => repo, :user => user)
      expect(comment.id).to eq(100)
      expect(comment.user_id).to eq(10)
    end
  end
end
