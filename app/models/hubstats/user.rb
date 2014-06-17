module Hubstats
  class User < ActiveRecord::Base

    scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}
    
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


    # # This is essentiall a single query
    def self.users_with_comments
      Hubstats::Comment.select("user_id")
      .select("IFNULL(COUNT(user_id),0) as user_comments")
      .where("created_at > ?", 2.weeks.ago)
      .group("user_id")
    end

    def self.users_with_pulls
      Hubstats::PullRequest.select("user_id")
      .select("IFNULL(COUNT(user_id),0) as user_pulls")
      .where("closed_at > ?", 2.weeks.ago)
      .group("user_id")
    end

    def self.pulls_and_comments
      Hubstats::PullRequest.select("hubstats_pull_requests.user_id")
        .select("IFNULL(COUNT(hubstats_pull_requests.user_id),0) as user_pulls")
        .select("IFNULL(user_comments,0) as user_comments")
        .joins("LEFT OUTER JOIN (#{users_with_comments().to_sql}) c ON c.user_id = hubstats_pull_requests.user_id")
        .where("closed_at > ?", 2.weeks.ago)
        .group("user_id")
    end

    def self.comments_and_pulls
      Hubstats::Comment.select("hubstats_comments.user_id")
        .select("IFNULL(COUNT(hubstats_comments.user_id),0) as user_comments")
        .select("IFNULL(user_pulls,0) as user_pulls")
        .joins("LEFT OUTER JOIN (#{users_with_pulls().to_sql}) c ON c.user_id = hubstats_comments.user_id")
        .where("created_at > ?", 2.weeks.ago)
        .group("user_id")
    end
 
    def self.with_recent_activity
      Hubstats::User.select("hubstats_users.login, hubstats_users.html_url, hubstats_users.id")
      .select("IFNULL(q.user_pulls,0) as num_pulls, IFNULL(q.user_comments,0) as num_comments")
      .joins("LEFT OUTER JOIN (#{pulls_and_comments().to_sql} UNION #{comments_and_pulls.to_sql}) q on q.user_id = hubstats_users.id")
      .where("q.user_pulls > 0 OR q.user_comments > 0")
      .order("q.user_pulls*2 + q.user_comments DESC")
    end 

    def to_param
      self.login
    end
  end
end
