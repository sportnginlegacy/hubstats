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

        # finds the total number of additions or deletions for all pull requests in this deploy
    def total_changes(add)
      pull_requests = self.pull_requests
      total = 0
      pull_requests.each do |pull|
        if add == :additions
          total += pull.additions.to_i
        elsif add == :deletions
          total += pull.deletions.to_i
        end
      end
      return total
    end

    # finds all of the additions and deletions in all pull requests and then makes the net additions
    def find_net_additions
      pull_requests = self.pull_requests
      total_additions = 0
      total_deletions = 0
      pull_requests.each do |pull|
        total_additions += pull.additions.to_i
        total_deletions += pull.deletions.to_i
      end
      return total_additions - total_deletions
    end

    # returns the total amount of comments from all pull requests in a deploy
    def find_comment_count
      pull_requests = self.pull_requests
      total_comments = 0
      pull_requests.each do |pull|
        total_comments += Hubstats::Comment.belonging_to_pull_request(pull.id).count(:all)
      end
      return total_comments
    end

  end
end
