require_dependency "hubification/application_controller"

module Hubification
  class SplashController < ApplicationController
    def index
      client = Hubification::GithubAPI.client

      @pull_requests = Hubification::GithubAPI.since(2.weeks.ago, :sort => "created")
    end
  end
end
