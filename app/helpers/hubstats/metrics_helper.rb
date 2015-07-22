module Hubstats
  module MetricsHelper
    # include ActionView::Helpers::ApplicationHelper
    # Public - Shows statistics for all of the data Hubstats has within the date range
    #
    # Returns - the stats for the entirety of Hubstats
    def dashboard
      developer_count = Hubstats::User.count_active_developers(@start_date, @end_date)
      reviewer_count = Hubstats::User.count_active_reviewers(@start_date, @end_date)
      deploy_count = Hubstats::Deploy.deployed_in_date_range(@start_date, @end_date).count(:all)
      pull_count = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).count(:all)
      comment_count = Hubstats::Comment.created_in_date_range(@start_date, @end_date).count(:all)
      
      if reviewer_count != 0
        comments_per_rev = (comment_count.to_f / reviewer_count.to_f).round(2)
      else
        comments_per_rev = 0
      end

      if developer_count != 0
        pulls_per_dev = (pull_count.to_f / developer_count.to_f).round(2)
      else
        pulls_per_dev = 0
      end

      net_additions = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).sum(:additions).to_i - 
                      Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).sum(:deletions).to_i
      additions = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).average(:additions) || 0
      deletions = Hubstats::PullRequest.merged_in_date_range(@start_date, @end_date).average(:deletions) || 0

      @stats_row_one = {
        developer_count: developer_count,
        pull_count: pull_count,
        pulls_per_dev: pulls_per_dev,
        deploy_count: deploy_count,
        net_additions: net_additions
      }
      @stats_row_two = {
        reviewer_count: reviewer_count,
        comment_count: comment_count,
        comments_per_rev: comments_per_rev,
        avg_additions: additions.round.to_i,
        avg_deletions: deletions.round.to_i
      }
    end
  end
end
