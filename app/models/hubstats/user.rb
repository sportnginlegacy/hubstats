module Hubstats
  class User < ActiveRecord::Base

    attr_accessible :login, :id, :avatar_url, :gravatar_id, :url, :html_url, :followers_url,
      :following_url, :gists_url, :starred_url, :subscriptions_url, :organizations_url,
      :repos_url, :events_url, :received_events_url, :role, :site_admin
    
    validates :id, presence: true, uniqueness: true

    has_many :comments
    has_many :repos, :class_name => "Repo"
    has_many :pull_requests

    def self.find_or_create_user(github_user)
      github_user[:role] = github_user.delete :type  ##changing :type in to :role
      github_user = github_user.to_h unless github_user.is_a? Hash
      user_data = github_user.slice(*Hubstats::User.column_names.map(&:to_sym))
      user = Hubstats::User.where(:id => user_data[:id]).first_or_create(user_data)
      return user if user.save
      Rails.logger.debug user.errors.inspect
    end


    # This is essentiall a single query
    def self.comments_by_id
      Hubstats::Comment.select("user_id")
      .select("IFNULL(COUNT(user_id),0) as user_comments")
      .where("created_at > ?", 2.weeks.ago)
      .group("user_id")
    end

    def self.pulls_by_id
      Hubstats::PullRequest.select("hubstats_pull_requests.user_id")
        .select("IFNULL(COUNT(hubstats_pull_requests.user_id),0) as user_pulls")
        .select("IFNULL(j.user_comments,0) as user_comments")
        .joins("LEFT OUTER JOIN (#{comments_by_id().to_sql}) j ON j.user_id = hubstats_pull_requests.user_id")
        .where("closed_at > ?", 2.weeks.ago)
        .group("hubstats_pull_requests.user_id")
    end

    def self.with_recent_activity
      Hubstats::User.select("hubstats_users.login, hubstats_users.html_url, hubstats_users.id")
      .select("q.user_pulls as num_pulls, q.user_comments as num_comments")
      .joins("RIGHT OUTER JOIN (#{pulls_by_id().to_sql}) q on q.user_id = hubstats_users.id")
      .order("q.user_pulls*2 + q.user_comments DESC")
    end 

    def to_param
      self.login
    end
  end
end
