require_dependency "hubification/application_controller"

module Hubification
  class SplashController < ApplicationController
    def index
      client = Hubification::GithubAPI.new

      @pull_requests = Hubification::GithubAPI.since(2.weeks.ago, :sort => "created").sort{|a,b| b[:closed_at] <=> a[:closed_at]}
      @comments = Hubification::User.select("hubification_users.login, hubification_users.html_url")
        .select("IFNULL(COUNT(c.user_id),0) as num_comments")
        .joins('LEFT OUTER JOIN hubification_comments c ON c.user_id = hubification_users.id')
        .group("hubification_users.id")
        .order("num_comments DESC")
    end
  end
end
