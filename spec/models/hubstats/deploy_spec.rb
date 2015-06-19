require 'spec_helper'

module Hubstats
  describe Deploy, :type => :model do
    it 'should create a deploy and check validations' do
      repo = build(:repo)
      deploy_hash = {git_revision: "c1a2b37", 
                     repo_id: repo.id,
                     deployed_at: "2009-02-03 03:00:00 -0500", 
                     user_id: 202020}
      deploy = Deploy.create(deploy_hash)
      expect(Deploy.count).to eq(1)
      expect(deploy.git_revision).to eq("c1a2b37")
      expect(deploy.repo_id).to eq(repo.id)
      expect(deploy.deployed_at).to eq("2009-02-03 03:00:00 -0500")
      expect(deploy.user_id).to eq(202020)
    end

    it 'should order deploys based on date range ASC' do
      repo = build(:repo)
      deploy1 = Deploy.create(git_revision: "c1a2b37",
                              repo_id: repo.id, 
                              deployed_at: "2009-12-03 23:00:00", 
                              user_id: 202020)
      deploy2 = Deploy.create(git_revision: "kd92h10",
                              repo_id: repo.id, 
                              deployed_at: "2010-05-26 22:00:00", 
                              user_id: 202020)
      deploy3 = Deploy.create(git_revision: "k10d8as",
                              repo_id: repo.id, 
                              deployed_at: "2015-03-21 12:00:00", 
                              user_id: 202020)
      deploy4 = Deploy.create(git_revision: "917d9ss",
                              repo_id: repo.id, 
                              deployed_at: "2014-12-19 08:00:00", 
                              user_id: 202020)
      deploys_ordered = [deploy1, deploy2, deploy4, deploy3]
      new_ordered_deploys = Deploy.order_with_date_range("2005-07-01", "2015-06-19", "ASC")
      expect(Deploy.count).to eq(4)
      expect(new_ordered_deploys).to eq(deploys_ordered)
    end

    it 'should order deploys based on date range DESC' do
      repo = build(:repo)
      deploy1 = Deploy.create(git_revision: "c1a2b37",
                              repo_id: repo.id, 
                              deployed_at: "2009-12-03 23:00:00", 
                              user_id: 202020)
      deploy2 = Deploy.create(git_revision: "kd92h10",
                              repo_id: repo.id, 
                              deployed_at: "2010-05-26 22:00:00", 
                              user_id: 202020)
      deploy3 = Deploy.create(git_revision: "k10d8as",
                              repo_id: repo.id, 
                              deployed_at: "2015-03-21 12:00:00", 
                              user_id: 202020)
      deploy4 = Deploy.create(git_revision: "917d9ss",
                              repo_id: repo.id, 
                              deployed_at: "2014-12-19 08:00:00", 
                              user_id: 202020)
      deploys_ordered = [deploy3, deploy4, deploy2, deploy1]
      new_ordered_deploys = Deploy.order_with_date_range("2005-07-01", "2015-06-19", "DESC")
      expect(Deploy.count).to eq(4)
      expect(new_ordered_deploys).to eq(deploys_ordered)
    end

    it 'should NOT create a deploy without a git_revision' do
      repo = build(:repo)
      expect(Deploy.create(git_revision: nil, 
                           repo_id: repo.id, 
                           deployed_at: "2009-02-03 03:00:00 -0500", 
                           user_id: 202020)).not_to be_valid
    end

    it 'should NOT create a deploy without a repo_id' do
      repo = build(:repo)
      expect(Deploy.create(git_revision: "c1a2b37", 
                           repo_id: nil, 
                           deployed_at: "2009-02-03 03:00:00 -0500", 
                           user_id: 202020)).not_to be_valid
    end


    it 'should create a deploy without a user_id' do
      repo = build(:repo)
      expect(Deploy.create(git_revision: "c1a2b37", 
                           repo_id: repo.id, 
                           deployed_at: "2009-02-03 03:00:00 -0500", 
                           user_id: nil)).to be_valid
    end

    it 'should create a deploy wihtout a deployed_at because nil time turns into current time' do
      repo = build(:repo)
      expect(Deploy.create(git_revision: "c1a2b37", 
                           repo_id: repo.id, 
                           deployed_at: nil, 
                           user_id: 202020)).to be_valid
    end

    it 'should NOT create a deploy with an invalid repo_id' do
      repo = build(:repo, :id => nil,
                          :name => nil,
                          :full_name => nil)
      expect(Deploy.create(git_revision: "c1a2b37", 
                           repo_id: repo.id, 
                           deployed_at: "2009-02-03 03:00:00 -0500", 
                           user_id: 202020)).not_to be_valid
    end
  end
end
