require_dependency "hubstats/application_controller"

module Hubstats
  class UsersController < ApplicationController

    def index 
      @users = Hubstats::User.with_pulls_or_comments(@timespan)
    end

    def show
      @user = Hubstats::User.where(login: params[:id]).first
      @pulls = Hubstats::PullRequest.belonging_to_user(@user.id).closed_since(@timespan)
      @comments = Hubstats::Comment.belonging_to_user(@user.id).created_since(@timespan)
      @repos = Hubstats::Repo
    end
  end
end
