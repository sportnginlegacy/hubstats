require 'spec_helper'

module Hubstats
  describe DeploysController, :type => :controller do
    routes { Hubstats::Engine.routes }
    
    describe "#index" do
      it "should correctly order all of the deploys" do
        repo = create(:repo, :full_name => "sportngin/ngin")
        deploy1 = create(:deploy, :git_revision => "c1a2b37",
                                  :repo_id => 101010,
                                  :deployed_at => "2009-02-03 03:00:00 -0500",
                                  :user_id => 404040)
        deploy2 = create(:deploy, :git_revision => "kd9c102",
                                  :repo_id => 101010,
                                  :deployed_at => "2015-02-03 03:00:00 -0500",
                                  :user_id => 303030)
        deploy3 = create(:deploy, :git_revision => "owk19sf",
                                  :repo_id => 101010,
                                  :deployed_at => "2011-02-03 03:00:00 -0500",
                                  :user_id => 202020)
        deploy4 = create(:deploy, :git_revision => "owk19sf",
                                  :repo_id => 101010,
                                  :deployed_at => "2011-02-03 03:00:00 -0500",
                                  :user_id => nil)
        deploys_ordered = [deploy2, deploy3, deploy1]
        expect(Hubstats::Deploy).to receive_message_chain("group_by.order_with_date_range.paginate").and_return(deploys_ordered)
        get :index
        expect(response).to have_http_status(200)
        expect(response).to render_template(:index)
      end
    end

    describe "#show" do
      it "should show the pull requests of the specific deploy" do
        repo = create(:repo, :full_name => "sportngin/ngin")
        deploy = create(:deploy, :git_revision => "c1a2b37",
                                 :repo_id => 101010,
                                 :deployed_at => "2009-02-03 03:00:00 -0500")
        pull1 = create(:pull_request, :deploy_id => deploy.id, :repo => repo)
        pull2 = create(:pull_request, :deploy_id => deploy.id, :repo => repo)
        get :show, id: deploy.id
        expect(assigns(:deploy)).to eq(deploy)
        expect(assigns(:pull_requests)).to contain_exactly(pull1, pull2)
        expect(assigns(:deploy).repo_id).to eq(101010)
      end
    end

    describe "#create" do
      before :each do
        create(:pull_request, :number => 33364992, :merged_by => 202020)
      end

      it 'should create a deploy' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "hub/hubstats",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => "33364992, 5870592, 33691392"})
        expect(assigns(:deploy).git_revision).to eq("c1a2b37")
        expect(assigns(:deploy).deployed_at).to eq("2009-02-03 03:00:00 -0500")
        expect(assigns(:deploy).repo_id).to eq(101010)
        expect(assigns(:deploy).user_id).to eq(202020)
        expect(response).to have_http_status(200)
      end

      it 'should create a deploy without a deployed_at because nil time turns into current time' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "hub/hubstats",
                       "deployed_at" => nil,
                       "pull_request_ids" => "33364992, 5870592, 33691392"})
        expect(assigns(:deploy).git_revision).to eq("c1a2b37")
        expect(assigns(:deploy).repo_id).to eq(101010)
        expect(assigns(:deploy).user_id).to eq(202020)
        expect(response).to have_http_status(200)
      end

      it 'should NOT create a deploy without a git_revision' do
        post(:create, {"git_revision" => nil,
                       "repo_name" => "hub/hubstats",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => "33364992, 5870592, 33691392"})
        expect(response).to have_http_status(400)
      end

      it 'should create a deploy without a user_id' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "hub/hubstats",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => "33364992, 5870592, 33691392"})
        expect(response).to have_http_status(200)
      end

      it 'should NOT create a deploy without a repo_name' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => nil,
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => "33364992, 5870592, 33691392"})
        expect(response).to have_http_status(400)
      end

      it 'should NOT create a deploy when given a non existing repo_name' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "sportngin/example",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => "33364992, 5870592, 33691392"})
        expect(response).to have_http_status(400)
      end

      it 'should NOT create a deploy without pull request ids' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "hub/hubstats",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => nil})
        expect(response).to have_http_status(400)
      end

      it 'should NOT create a deploy when given empty pull request ids' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "hub/hubstats",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => ""})
        expect(response).to have_http_status(400)
      end

      it 'should NOT create a deploy when given something that are not pull request ids' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "hub/hubstats",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => "blah bleh blooh"})
        expect(response).to have_http_status(400)
      end

      it 'should NOT create a deploy when given invalid pull request ids' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "hub/hubstats",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "pull_request_ids" => "77, 81, 92"})
        expect(response).to have_http_status(400)
      end
    end
  end
end
