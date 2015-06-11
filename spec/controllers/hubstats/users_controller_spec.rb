require 'spec_helper'

module Hubstats
  describe UsersController, :type => :controller do
    routes { Hubstats::Engine.routes }

    describe "#show" do
      it "should show the pull requests and deploys of specific user" do
        user = create(:user, :id => 101010, :login => "examplePerson")
        pull1 = create(:pull_request, :user => user, :id => 202020)
        pull2 = create(:pull_request, :user => user, :id => 303030, :repo => pull1.repo)
        deploy1 = create(:deploy, :user_id => 101010)
        deploy2 = create(:deploy, :user_id => 101010)
        get :show, id: "examplePerson"
        expect(assigns(:user)).to eq(user)
        expect(assigns(:user).pull_requests).to contain_exactly(pull1, pull2)
        expect(assigns(:user).deploys).to contain_exactly(deploy1, deploy2)
      end
    end

    describe "#index" do
      # it "should show all of the repos" do        repo1 = create(:repo, :id => 101010,
      #                         :name => "silly",
      #                         :full_name => "sportngin/silly")
      #   repo2 = create(:repo, :id => 202020,
      #                         :name => "funny",
      #                         :full_name => "sportngin/funny")
      #   repo3 = create(:repo, :id => 303030,
      #                         :name => "loosey",
      #                         :full_name => "sportngin/loosey")
      #   repo4 = create(:repo, :id => 404040,
      #                         :name => "goosey",
      #                         :full_name => "sportngin/goosey")
      #   get :index
      #   expect(assigns(:repos)).to contain_exactly(repo2, repo1, repo3, repo4)
      # end
    end
  
  end
end
