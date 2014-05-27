require_dependency "hubification/application_controller"

module Hubification
  class SplashController < ApplicationController
    def index
      client = Octokit::Client.new(:login => 'elliothursh', :password => ENV['GITHUB_PASS'])
      @user = Octokit.user 'anfleene'

    end
  end
end
