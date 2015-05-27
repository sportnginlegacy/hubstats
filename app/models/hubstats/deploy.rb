module Hubstats
	class Deploy < ActiveRecord::Base
		# git revision as string
		# repo ID as integer
		# deployed_at as timestamp
		# deployed_by as username string

		scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}
    scope :belonging_to_repos, lambda {|repo_id| where(repo_id: repo_id.split(',')) if repo_id}
    scope :belonging_to_users, lambda {|user_id| where(user_id: user_id.split(',')) if user_id}
    scope :order_with_timespan
    #scope :has_many_pull_requests, lambda {|| where(....)}

		attr_accessible :git_revision, :repo_id, :deployed_at, :deployed_by

		belongs_to :user
		belongs_to :repo
		has_many :pull_requests

		#the below method is all about the timespan and ordering thing
		def self.order_with_timespan(timespan, order)
			# order is whatever the order_type is as an uppercase string or it's "DESC"
      order = ["ASC", "DESC"].detect{|order_type| order_type.to_s == order.to_s.upcase } || "DESC"
      order("hubstats_deploys.deployed_at #{order}")
     #   order("hubstats_deploys.deployed_at ASC")
    end

    def self.group_by(group)
      if group == 'user'
        with_user_name.order("user_name ASC")
      elsif group == 'repo'
        with_repo_name.order("repo_name asc")
      else
        scoped
      end
    end

	end
end
