require "spec_helper"

module Hubstats
  describe Repo, :type => :model do
  	it "should create a repo" do
  		repo_hash = {id: 131242,
  		             owner_id: 3728684,
  		             name: "example_name",
  		             full_name: "sportngin/example_name",
  		             pushed_at: "2015-05-27 13:51:21 -0500",
  		             created_at: "2009-05-27 06:27:04 -0500",
  		             updated_at: "2015-03-26 16:17:19 -0500"}
  		repo = Repo.create(repo_hash)
  		expect(repo.id).to eq(repo_hash[:id])
  		expect(repo.owner).to eq(repo_hash[:owner])
  		expect(repo.name).to eq(repo_hash[:name])
  		expect(repo.full_name).to eq(repo_hash[:full_name])
  		expect(repo.pushed_at).to eq(repo_hash[:pushed_at])
  		expect(repo.created_at).to eq(repo_hash[:created_at])
  		expect(repo.updated_at).to eq(repo_hash[:updated_at])
    end
  end
end
