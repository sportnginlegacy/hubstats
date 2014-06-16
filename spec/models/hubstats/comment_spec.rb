require 'spec_helper'

module Hubstats
  describe Comment, :type => :model do
    it 'creates and returns a comment and user' do
      github_user = {
        :login => "elliothursh",
        :id => 10,
        :type => "User"
      }

      github_comment = {
        :user => github_user,
        :pull_request_url => "www.pull.com",
        :id => 100
      }

      github_repo = {
        :id => 151,
        :name => "HellWorld"
      }

      pull_request = {
        :id => 1000,
        :url => "www.pull.com",
        :base => {:repo => github_repo},
        :user => github_user
      }

      repo = Hubstats::Repo.find_or_create_repo(github_repo)
      pull = Hubstats::PullRequest.find_or_create_pull(pull_request)
      comment = Hubstats::Comment.find_or_create_comment(github_comment)

      expect(comment.id).to eq(github_comment[:id])
      expect(comment.user_id).to eq(github_user[:id])
    end
  end
end
