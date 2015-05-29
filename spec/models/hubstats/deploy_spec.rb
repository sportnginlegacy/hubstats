require 'spec_helper'

module Hubstats
  describe Deploy, :type => :model do
    it 'creates a deploy and checks validations' do
      repo = build(:repo)

      deploy_hash = {
        git_revision: "c1a2b37", 
        repo_id: repo.id,
        deployed_at: "2009-02-03 03:00:00 -0500", 
        deployed_by: "emmasax1"
      }

      @deploy = Deploy.create(deploy_hash)

      expect(Deploy.count).to eq(1)
      expect(@deploy.git_revision).to eq(deploy_hash[:git_revision])
      expect(@deploy.repo_id).to eq(deploy_hash[:repo_id])
      expect(@deploy.deployed_at).to eq(deploy_hash[:deployed_at])
      expect(@deploy.deployed_by).to eq(deploy_hash[:deployed_by])
    end

    it 'orders deploys based on timespan' do
      repo = build(:repo)

      @deploy1 = Deploy.create({git_revision: "c1a2b37",
                                repo_id: repo.id, 
                                deployed_at: "2009-12-03 23:00:00", 
                                deployed_by: "emmasax1"})
      @deploy2 = Deploy.create({git_revision: "kd92h10",
                                repo_id: repo.id, 
                                deployed_at: "2010-05-26 22:00:00", 
                                deployed_by: "odelltuttle"})
      @deploy3 = Deploy.create({git_revision: "k10d8as",
                                repo_id: repo.id, 
                                deployed_at: "2015-08-21 12:00:00", 
                                deployed_by: "EvaMartinuzzi"})
      @deploy4 = Deploy.create({git_revision: "917d9ss",
                                repo_id: repo.id, 
                                deployed_at: "2014-12-19 08:00:00", 
                                deployed_by: "panderson74"})

      @deploys_ordered1 = [@deploy3, @deploy4, @deploy2, @deploy1]
      @deploys_ordered2 = [@deploy1, @deploy2, @deploy4, @deploy3]

      expect(Deploy.count).to eq(4)

      @new_ordered_deploys1 = Deploy.order_with_timespan(520.weeks, "DESC")
      @new_ordered_deploys2 = Deploy.order_with_timespan(520.weeks, "ASC")

      expect(@new_ordered_deploys1).to eq(@deploys_ordered1)
      expect(@new_ordered_deploys2).to eq(@deploys_ordered2)
    end

    it 'should error when not given a git_revision, repo_id, or deployed_by' do
      repo = build(:repo)

      expect(FactoryGirl.build(:deploy, :git_revision => "c1a2b37", 
                                        :repo_id => repo.id, 
                                        :deployed_at => "2009-02-03 03:00:00 -0500", 
                                        :deployed_by => nil)).not_to be_valid

      expect(FactoryGirl.build(:deploy, :git_revision => nil, 
                                        :repo_id => repo.id, 
                                        :deployed_at => "2009-02-03 03:00:00 -0500", 
                                        :deployed_by => "emmasax1")).not_to be_valid

      expect(FactoryGirl.build(:deploy, :git_revision => "c1a2b37", 
                                        :repo_id => nil, 
                                        :deployed_at => "2009-02-03 03:00:00 -0500", 
                                        :deployed_by => "emmasax1")).not_to be_valid
    end

    it 'should pass when not given a deployed_at' do
      repo = build(:repo)

      expect(FactoryGirl.build(:deploy, :git_revision => "c1a2b37", 
                                        :repo_id => repo.id, 
                                        :deployed_at => nil, 
                                        :deployed_by => "emmasax1")).to be_valid
    end
  end
end

