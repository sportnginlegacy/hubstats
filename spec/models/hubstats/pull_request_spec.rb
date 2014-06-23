require 'spec_helper'

module Hubstats
  describe PullRequest, :type => :model do
    it 'creates and returns a pull request and user' do
      github_user = {
        :login => "elliothursh",
        :id => 10,
        :type => "User"
      }

      github_repo = {
        :id => 151,
        :name => "HellWorld"
      }

      github_pull = {
        :user => github_user,
        :repository => github_repo,
        :id => 100
      }

      repo = Hubstats::Repo.create_or_update_repo(github_repo)
      pull = Hubstats::PullRequest.find_or_create_pull(github_pull)

      expect(pull.id).to eq(github_pull[:id])
      expect(pull.user_id).to eq(github_user[:id])
      expect(pull.repo_id).to eq(github_repo[:id])
    end
  end
end
