module Hubstats
  class Deploy < ActiveRecord::Base

    before_validation :check_time, on: :create
    validates :git_revision, :deployed_at, :repo_id, presence: true

    # Public - Checks if there is a deployed_at for a new deploy; if there isn't, then assign it the current time.
    #
    # Returns - the current time or the actual deployed_at time
    def check_time
        self.deployed_at = Time.now.getutc if deployed_at.nil?
    end

    # Various checks that can be used to filter, sort, and find info about deploys.
    scope :deployed_in_date_range, lambda {|start_date, end_date| where("hubstats_deploys.deployed_at BETWEEN ? AND ?", start_date, end_date)}
    scope :group, lambda {|group| group_by(:repo_id) if group }
    scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}
    scope :belonging_to_repos, lambda {|repo_id| where(repo_id: repo_id.split(',')) if repo_id}
    scope :belonging_to_users, lambda {|user_id| where(user_id: user_id.split(',')) if user_id}
    scope :with_repo_name, select('DISTINCT hubstats_repos.name as repo_name, hubstats_deploys.*').joins("LEFT JOIN hubstats_repos ON hubstats_repos.id = hubstats_deploys.repo_id")
    scope :with_user_name, select('DISTINCT hubstats_users.login as user_name, hubstats_deploys.*').joins("LEFT JOIN hubstats_users ON hubstats_users.id = hubstats_deploys.user_id")

    attr_accessible :git_revision, :repo_id, :deployed_at, :user_id, :pull_request_ids

    belongs_to :user
    belongs_to :repo
    has_many :pull_requests

    # Public - Orders the deploys within the start_date and end_date with by a given order.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # order - the designated order to sort the data 
    #
    # Returns - the deploy data ordered
    def self.order_with_date_range(start_date, end_date, order)
      order = ["ASC", "DESC"].detect{|order_type| order_type.to_s == order.to_s.upcase } || "DESC"
      deployed_in_date_range(start_date, end_date).order("hubstats_deploys.deployed_at #{order}")
    end

    # Public - Groups the deploys based on the string passed in: 'user' or 'repo'.
    # 
    # group - string that is the designated grouping
    #
    # Returns - the data grouped
    def self.group_by(group)
       if group == "user"
         with_user_name.order("user_name ASC")
       elsif group == "repo"
         with_repo_name.order("repo_name ASC")
       else
         scoped
       end
    end

    # Public - Gathers all PRs for a deploy, and then either finds all of the additions or all of the 
    # deletions, depending on the symbol passed in.
    #
    # add - symbol that reflects the type of data we want to add up
    #
    # Returns - the total amount that has been added; either deletions or additions 
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

    # Public - Gathers all PRs for a deploy, and then finds all of the additions and all of the deletions,
    # then subtracts them to find the number of net additions.
    #
    # Returns - the total number of deletions subtracted from the total number of additions
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

    # Public - Gathers all of the PRs and then counts all of the comments that are assigned to each PR.
    #
    # Returns the total amount of comments that all PRs to a deploy has
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
