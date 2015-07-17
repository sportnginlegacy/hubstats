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
      expect(pull_request.merged_by).to eq(nil)
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

    it "should track the team_id when making a pull request" do
      user_hash = {login: 'name', id: '12345'}
      user = User.create(user_hash)
      team = create(:team, id: 1010)
      team.users << user
      pull = build(:pull_request_hash, :user => user_hash)
      pull_request = PullRequest.create_or_update(pull)
      expect(pull_request.user_id).to eq(user[:id])
      expect(pull_request.team_id).to eq(team[:id])
    end

    it "should leave the team_id of a pull request blank if user is not part of a team" do
      user_hash = {login: 'name', id: '12345'}
      user = User.create(user_hash)
      pull = build(:pull_request_hash, :user => user_hash)
      pull_request = PullRequest.create_or_update(pull)
      expect(pull_request.user_id).to eq(user[:id])
      expect(pull_request.team_id).to eq(nil)
    end

    it 'should update the team_ids in pull requests' do
      team = build(:team)
      repo = build(:repo)
      user1 = build(:user)
      user2 = build(:user, :id => 7)
      team.users << user1
      team.users << user2
      pull1 = build(:pull_request, :created_at => Date.today - 250, :user => user1)
      pull2 = build(:pull_request, :created_at => Date.today - 3, :repo => repo, :user => user2)
      Hubstats::PullRequest.update_teams_in_pulls
      expect(pull1.team_id).to eq(team.id)
      expect(pull2.team_id).to eq(team.id)
    end
  end
end
