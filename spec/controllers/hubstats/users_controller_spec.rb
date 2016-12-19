require 'spec_helper'

module Hubstats
  describe UsersController, :type => :controller do
    routes { Hubstats::Engine.routes }

    describe "#index" do
      it "should show all of the users" do
        user2 = create(:user, :id => 101010, :login => "examplePerson1", :updated_at => Date.today)
        user1 = create(:user, :id => 202020, :login => "examplePerson2", :updated_at => Date.today)
        user3 = create(:user, :id => 303030, :login => "examplePerson3", :updated_at => Date.today)
        user4 = create(:user, :id => 404040, :login => "examplePerson4", :updated_at => Date.today)
        expect(Hubstats::User).to receive_message_chain("with_id.custom_order.paginate").and_return([user2, user3, user1, user4])
        allow(Hubstats).to receive_message_chain(:config, :github_config, :[]).with("ignore_users_list") { ["user"] }
        get :index
        expect(response).to have_http_status(200)
      end
    end

    describe "#show" do
      it "should show the pull requests and deploys of specific user" do
        user = create(:user, :id => 101010, :login => "examplePerson", :updated_at => Date.today)
        repo = create(:repo, :updated_at => Date.today)
        pull1 = create(:pull_request, :user => user, :id => 202020, :updated_at => Date.today, :repo_id => repo.id)
        pull2 = create(:pull_request, :user => user, :id => 303030, :repo => pull1.repo, :updated_at => Date.today)
        deploy1 = create(:deploy, :user_id => 101010)
        deploy2 = create(:deploy, :user_id => 101010)
        comment1 = create(:comment, :user => user, :updated_at => Date.today)
        comment2 = create(:comment, :user => user, :updated_at => Date.today)
        allow(Hubstats).to receive_message_chain(:config, :github_config, :[]).with("ignore_users_list") { ["user"] }
        get :show, id: "examplePerson"
        expect(assigns(:user)).to eq(user)
        expect(assigns(:user).pull_requests).to contain_exactly(pull1, pull2)
        expect(assigns(:user).deploys).to contain_exactly(deploy1, deploy2)
        expect(assigns(:user).comments).to contain_exactly(comment2, comment1)
        expect(response).to have_http_status(200)
      end
    end
  end
end
