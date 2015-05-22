module Hubstats
	class Deploy < ActiveRecord::Base
		# git revision as string
		# repo ID as integer
		# deployed_at as timestamp
		# deployed_by as username string

		attr_accessible :git_revision, :repo_id, :deployed_at, :deployed_by

		belongs_to :user
		belongs_to :repo
		has_many :pull_requests
	end
end
