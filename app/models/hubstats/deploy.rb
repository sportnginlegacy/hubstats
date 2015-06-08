module Hubstats
  class Deploy < ActiveRecord::Base

    before_validation :check_time, on: :create
    validates :git_revision, :deployed_at, :repo_id, presence: true

    def check_time
        self.deployed_at = Time.now.getutc if deployed_at.nil?
    end

    scope :deployed_since, lambda {|time| where("hubstats_deploys.deployed_at > ?", time)}
    scope :group, lambda {|group| group_by(:repo_id) if group }
    scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}
    scope :belonging_to_repos, lambda {|repo_id| where(repo_id: repo_id.split(',')) if repo_id}
    scope :belonging_to_users, lambda {|user_id| where(user_id: user_id.split(',')) if user_id}
    scope :order_with_timespan
    scope :with_repo_name, select('DISTINCT hubstats_repos.name as repo_name, hubstats_deploys.*').joins("LEFT JOIN hubstats_repos ON hubstats_repos.id = hubstats_deploys.repo_id")
    scope :with_user_name, select('DISTINCT hubstats_users.login as user_name, hubstats_deploys.*').joins("LEFT JOIN hubstats_users ON hubstats_users.id = hubstats_deploys.user_id")

    attr_accessible :git_revision, :repo_id, :deployed_at, :user_id, :pull_request_ids

    belongs_to :user
    belongs_to :repo
    has_many :pull_requests

    # Order the data in a given timespan in a given order
    def self.order_with_timespan(timespan, order)
      order = ["ASC", "DESC"].detect{|order_type| order_type.to_s == order.to_s.upcase } || "DESC"
      deployed_since(timespan).order("hubstats_deploys.deployed_at #{order}")
    end

    # Sorts based on whether data is being grouped by user or repo
    def self.group_by(group)
       if group == "user"
         with_user_name.order("user_name ASC")
       elsif group == "repo"
         with_repo_name.order("repo_name ASC")
       else
         scoped
       end
    end

  end
end
