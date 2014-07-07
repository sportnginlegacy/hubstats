require 'spec_helper'

module Hubstats
  describe PullRequest, :type => :model do
    it 'creates and returns a PullRequest' do
      pull = build(:pull_request_hash)
      pull_request = Hubstats::PullRequest.create_or_update(pull)
      expect(pull_request.id).to eq(pull[:id])
      expect(pull_request.user_id).to eq(pull[:user][:id])
      expect(pull_request.repo_id).to eq(pull[:repository][:id])
    end
  end
end
