module Hubstats
  class User < ActiveRecord::Base
    attr_accessible :login, :id, :avatar_url, :gravatar_id, :url, :html_url, :followers_url,
      :following_url, :gists_url, :starred_url, :subscriptions_url, :organizations_url,
      :repos_url, :events_url, :received_events_url, :role, :site_admin
    
    validates :id, presence: true, uniqueness: true

    has_many :comments
    has_many :repos, :class_name => "Repo"
    has_many :pull_requests
    has_many :merged_pulls, :class_name => "PullRequest", :foreign_key => "number"

    def self.pull_request_counts
      self.select("hubstats_users.login, hubstats_users.html_url, hubstats_users.id")
          .select("IFNULL(COUNT(p.user_id),0) as num_pulls")
          .joins('LEFT OUTER JOIN hubstats_pull_requests p ON p.user_id = hubstats_users.id')
          .group("hubstats_users.id")
    end

    def self.pull_requests_and_comments
      Hubstats::Comment.select("s.login, s.html_url, s.id, s.num_pulls")
        .select("IFNULL(COUNT(hubstats_comments.user_id),0) as num_comments")
        .joins("RIGHT OUTER JOIN (#{pull_request_counts().to_sql}) s ON hubstats_comments.user_id = s.id")
        .group("s.id")
        .order("s.login DESC")
    end
  end
end
