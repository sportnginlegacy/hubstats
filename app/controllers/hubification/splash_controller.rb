require_dependency "hubification/application_controller"

module Hubification
  class SplashController < ApplicationController
    def index
      client = GithubApi.client
      @user = client.user
    end
  end
end
