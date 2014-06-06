require_dependency "hubification/application_controller"

module Hubification
  class SplashController < ApplicationController
    def index
      client = Hubification::GithubAPI.new

      @pull_requests = Hubification::GithubAPI.since(2.weeks.ago, :sort => "created").sort{|a,b| b[:closed_at] <=> a[:closed_at]}
      subquery = Hubification::User.select("hubification_users.login, hubification_users.html_url, hubification_users.id")
        .select("IFNULL(COUNT(p.user_id),0) as num_pulls")
        .joins('LEFT OUTER JOIN hubification_pull_requests p ON p.user_id = hubification_users.id')
        .group("hubification_users.id").to_sql

      @users = Hubification::Comment.select("s.login, s.html_url, s.id, s.num_pulls")
        .select("IFNULL(COUNT(hubification_comments.user_id),0) as num_comments")
        .joins("RIGHT OUTER JOIN (#{subquery}) s ON hubification_comments.user_id = s.id")
        .group("s.id")
        .order("s.login DESC")





      # .select("hubification_users.login, hubification_users.html_url, hubification_users.id")
      #   .select("IFNULL(COUNT(c.user_id),0) as num_pulls")
      #   .joins('LEFT OUTER JOIN hubification_pull_requests p ON p.user_id = hubification_users.id')
      #   .group("hubification_users.id")
        


      #   .order("num_comments DESC")
    end
  end
end
