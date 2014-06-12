require_dependency "hubstats/application_controller"

module Hubstats
  class SplashController < ApplicationController
    def index

      @repos = Hubstats::Repo.where(["updated_at > '%s'", 1.months.ago]).sort{|a,b| b.updated_at <=> a.updated_at}
      @users = Hubstats::User.pull_requests_and_comments.sort{|a,b| (b.num_comments + b.num_pulls) <=> (a.num_comments + a.num_pulls)}[0..30]

    end
  end
end
