require 'spec_helper'

module Hubstats
  describe Repo, :type => :model do
  	it 'should create a repo' do
  		repo_hash = {id: 131242,
  		             owner_id: 3728684,
  		             name: "example_name",
  		             full_name: "sportngin/example_name",
  		             pushed_at: "2015-05-27 13:51:21 -0500",
  		             created_at: "2009-05-27 06:27:04 -0500",
  		             updated_at: "2015-03-26 16:17:19 -0500"}
  		repo = Repo.create(repo_hash)
  		expect(repo.id).to eq(131242)
  		expect(repo.owner_id).to eq(3728684)
  		expect(repo.name).to eq("example_name")
  		expect(repo.full_name).to eq("sportngin/example_name")
  		expect(repo.pushed_at).to eq("2015-05-27 13:51:21 -0500")
  		expect(repo.created_at).to eq("2009-05-27 06:27:04 -0500")
  		expect(repo.updated_at).to eq("2015-03-26 16:17:19 -0500")
    end
  end
end
