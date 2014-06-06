require_dependency "hubstats/application_controller"

module Hubstats
  class SplashController < ApplicationController
    def index

      @pull_requests = Hubstats::GithubAPI.since(2.weeks.ago, :sort => "created").sort{|a,b| b[:closed_at] <=> a[:closed_at]}
      @users = Hubstats::User.pull_requests_and_comments

    end
  end
end
