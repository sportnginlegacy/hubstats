require 'spec_helper'

module Hubstats
  describe PullRequest, :type => :model do
    it 'should create and return a pull request with a merge' do
      pull = build(:pull_request_hash)
      pull_request = PullRequest.create_or_update(pull)
      expect(pull_request.id).to eq(pull[:id])
      expect(pull_request.user_id).to eq(pull[:user][:id])
      expect(pull_request.repo_id).to eq(pull[:repository][:id])
      expect(pull_request.number).to eq(pull[:number])
      expect(pull_request.merged_by).to eq(202020)
    end

    it 'should create and return a pull request without a merge' do
      pull = build(:pull_request_hash_no_merge)
      pull_request = PullRequest.create_or_update(pull)
      expect(pull_request.id).to eq(pull[:id])
      expect(pull_request.user_id).to eq(pull[:user][:id])
      expect(pull_request.repo_id).to eq(pull[:repository][:id])
      expect(pull_request.number).to eq(pull[:number])
    end

    it "should create a pull request and update the deploy's user_id" do
      pull = build(:pull_request_hash)
      pull_request = PullRequest.create_or_update(pull)
      dep_hash = {git_revision: "c1a2b37", 
                  repo_id: 303030,
                  deployed_at: "2009-02-03 03:00:00 -0500", 
                  user_id: nil,
                  pull_request_ids: pull[:id]}
      deploy = Hubstats::Deploy.create!(dep_hash)
      pull_request.deploy = deploy
      pull_request = PullRequest.create_or_update(pull)
      expect(pull_request.id).to eq(pull[:id])
      expect(pull_request.user_id).to eq(pull[:user][:id])
      expect(pull_request.repo_id).to eq(pull[:repository][:id])
      expect(pull_request.number).to eq(pull[:number])
      expect(pull_request.merged_by).to eq(202020)
      expect(deploy.user_id).to eq(nil)
      expect(pull_request.deploy.user_id).to eq(202020)
    end
  end
end
