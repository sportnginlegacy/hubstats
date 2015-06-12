require 'spec_helper'

module Hubstats
  describe UsersController, :type => :controller do
    routes { Hubstats::Engine.routes }

    describe "#index" do
      it "should show all of the users" do
        user2 = create(:user, :id => 101010, :login => "examplePerson1")
        user1 = create(:user, :id => 202020, :login => "examplePerson2")
        user3 = create(:user, :id => 303030, :login => "examplePerson3")
        user4 = create(:user, :id => 404040, :login => "examplePerson4")
        expect(Hubstats::User).to receive_message_chain("with_id.custom_order.paginate").and_return([user2, user3, user1, user4])
        get :index
      end
    end

    describe "#show" do
      it "should show the pull requests and deploys of specific user" do
        user = create(:user, :id => 101010, :login => "examplePerson")
        pull1 = create(:pull_request, :user => user, :id => 202020)
        pull2 = create(:pull_request, :user => user, :id => 303030, :repo => pull1.repo)
        deploy1 = create(:deploy, :user_id => 101010)
        deploy2 = create(:deploy, :user_id => 101010)
        comment1 = create(:comment, :user => user)
        comment2 = create(:comment, :user => user)
        get :show, id: "examplePerson"
        expect(assigns(:user)).to eq(user)
        expect(assigns(:user).pull_requests).to contain_exactly(pull1, pull2)
        expect(assigns(:user).deploys).to contain_exactly(deploy1, deploy2)
        expect(assigns(:user).comments).to contain_exactly(comment2, comment1)
      end
    end
  end
end
