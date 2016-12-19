module Hubstats
  module MetricsHelper

    # Public - Gets the number of active developers within the start date and end date
    #
    # Returns - the number of developers
    def get_developer_count
      Hubstats::User.count_active_developers(@start_date, @end_date)
    end

    # Public - Gets the number of active reviewers within the start date and end date
    #
    # Returns - the number of reviewers
    def get_reviewer_count
      Hubstats::User.count_active_reviewers(@start_date, @end_date)
    end

    # Public - Gets the number of deployments within the start date and end date
    #
    # Returns - the number of deployments
    def get_deploy_count
      Hubstats::Deploy.deployed_in_date_range(@start_date, @end_date).count(:all)
    end

    # Public - Gets the number of pull requests within the start date and end date
    #
    # Returns - the number of pull requests
    def get_pull_count
      Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).ignore_pulls_by(Hubstats::User.ignore_users_ids).count(:all)
    end

    # Public - Gets the number of comments within the start date and end date
    #
    # Returns - the number of comments
    def get_comment_count
      Hubstats::Comment.created_in_date_range(@start_date, @end_date).ignore_comments_by(Hubstats::User.ignore_users_ids).count(:all)
    end

    # Public - Gets the number of comments per reviewer within the start date and end date
    #
    # Returns - the number of comments per reviewer
    def get_comments_per_rev
      if get_reviewer_count != 0
        comments_per_rev = (get_comment_count.to_f / get_reviewer_count.to_f).round(2)
      else
        comments_per_rev = 0
      end
    end

    # Public - Gets the number of pull requests per developer within the start date and end date
    #
    # Returns - the number of pull requests per developer
    def get_pulls_per_dev
      if get_developer_count != 0
        pulls_per_dev = (get_pull_count.to_f / get_developer_count.to_f).round(2)
      else
        pulls_per_dev = 0
      end
    end

    # Public - Gets the total net additions from all pull requests within the start date and end date
    #
    # Returns - the net additions
    def get_net_additions
      Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).sum(:additions).to_i - 
        Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).sum(:deletions).to_i
    end

    # Public - Gets the average number of additions from all pull requests within the start date and end date
    #
    # Returns - the average additions
    def get_avg_additions
      num = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).average(:additions) || 0
      return num.round.to_i
    end

    # Public - Gets the average number of deletions from all pull requests within the start date and end date
    #
    # Returns - the average deletions
    def get_avg_deletions
      num = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).average(:deletions) || 0
      return num.round.to_i
    end

    # Public - Formats statistics for all repos/users/teams of Hubstats
    #
    # Returns - all of the stats in a corresponding hash
    def dashboard
      @stats_row_one = {
        developer_count: get_developer_count,
        pull_count: get_pull_count,
        pulls_per_dev: get_pulls_per_dev,
        deploy_count: get_deploy_count,
        net_additions: get_net_additions
      }
      @stats_row_two = {
        reviewer_count: get_reviewer_count,
        comment_count: get_comment_count,
        comments_per_rev: get_comments_per_rev,
        avg_additions: get_avg_additions,
        avg_deletions: get_avg_deletions
      }
    end
  end
end
