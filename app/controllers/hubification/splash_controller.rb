require_dependency "hubification/application_controller"

module Hubification
  class SplashController < ApplicationController
    def index
      client = Hubification::GithubAPI.new

      @pull_requests = Hubification::GithubAPI.since(2.weeks.ago, :sort => "created").sort{|a,b| b[:closed_at] <=> a[:closed_at]}
      @users = Hubification::User.all.sort{|a,b| a[:login] <=> b[:login]}
    end
  end
end
