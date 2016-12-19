require 'spec_helper'

module Hubstats
  describe ReposController, :type => :controller do
    routes { Hubstats::Engine.routes }

    describe "#index" do
      it "should list all of the repos" do        
        repo1 = create(:repo, :id => 101010,
                              :name => "silly",
                              :full_name => "sportngin/silly",
                              :updated_at => Date.today)
        repo2 = create(:repo, :id => 202020,
                              :name => "funny",
                              :full_name => "sportngin/funny",
                              :updated_at => Date.today)
        repo3 = create(:repo, :id => 303030,
                              :name => "loosey",
                              :full_name => "sportngin/loosey",
                              :updated_at => Date.today)
        repo4 = create(:repo, :id => 404040,
                              :name => "goosey",
                              :full_name => "sportngin/goosey",
                              :updated_at => Date.today)
        allow(Hubstats).to receive_message_chain(:config, :github_config, :[]).with("ignore_users_list") { ["user"] }
        get :index
        expect(assigns(:repos)).to contain_exactly(repo2, repo1, repo3, repo4)
      end
    end

    describe "#show" do
      it "should show the pull requests and deploys of specific repository" do
        user = create(:user, :id => 606060, :updated_at => '2015-08-12')
        repo = create(:repo, :id => 101010,
                             :name => "example",
                             :full_name => "sportngin/example",
                             :owner_id => user.id,
                             :updated_at => Date.today)
        pull1 = create(:pull_request, :repo_id => 101010,
                                      :updated_at => "2015-06-02 19:49:42",
                                      :user => user)
        pull2 = create(:pull_request, :repo_id => 101010,
                                      :updated_at => "2015-04-21 17:06:31",
                                      :user => user)
        deploy1 = create(:deploy, :repo_id => 101010)
        deploy2 = create(:deploy, :repo_id => 101010)
        allow(Hubstats).to receive_message_chain(:config, :github_config, :[]).with("ignore_users_list") { ["user"] }
        get :show, repo: repo.name
        expect(assigns(:repo)).to eq(repo)
        expect(assigns(:repo).pull_requests).to contain_exactly(pull1, pull2)
        expect(assigns(:repo).deploys).to contain_exactly(deploy1, deploy2)
        expect(assigns(:repo).owner_id).to eq(user.id)
        expect(response).to have_http_status(200)
      end
    end

    describe "#index" do
      it "should list all of the repos and the basic metrics" do
        repo1 = create(:repo, :id => 101010,
                              :name => "silly",
                              :full_name => "sportngin/silly",
                              :updated_at => Date.today)
        repo2 = create(:repo, :id => 202020,
                              :name => "funny",
                              :full_name => "sportngin/funny",
                              :updated_at => Date.today)
        repo3 = create(:repo, :id => 303030,
                              :name => "loosey",
                              :full_name => "sportngin/loosey",
                              :updated_at => Date.today)
        repo4 = create(:repo, :id => 404040,
                              :name => "goosey",
                              :full_name => "sportngin/goosey",
                              :updated_at => Date.today)
        expect(Hubstats::Repo).to receive_message_chain("with_id.custom_order.paginate").and_return([repo1, repo2, repo3, repo4])
        allow(Hubstats).to receive_message_chain(:config, :github_config, :[]).with("ignore_users_list") { ["user"] }
        get :index
        expect(response).to have_http_status(200)
      end
    end
  end
end
