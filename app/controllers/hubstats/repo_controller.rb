require_dependency "hubstats/application_controller"

module Hubstats
  class RepoController < ApplicationController
    def show
      @pull_requests = Hubstats::PullRequest.where(["closed_at > '%s'", 2.weeks.ago]).sort{|a,b| b[:closed_at] <=> a[:closed_at]}
      @users = Hubstats::User.pull_requests_and_comments.sort{|a,b| (b.num_comments + b.num_pulls) <=> (a.num_comments + a.num_pulls)}
    end
  end
end
