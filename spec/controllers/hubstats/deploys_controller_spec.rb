require 'spec_helper'

module Hubstats
  describe DeploysController, :type => :controller do
    routes { Hubstats::Engine.routes }
    describe "#create" do

      before :each do
        create(:repo, :full_name => "sportngin/ngin")
      end

      it 'should create a deploy' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "sportngin/ngin",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "deployed_by" => "emmasax1"})
        expect(assigns(:deploy).git_revision).to eq("c1a2b37")
        expect(assigns(:deploy).deployed_at).to eq("2009-02-03 03:00:00 -0500")
        expect(assigns(:deploy).deployed_by).to eq("emmasax1")
        expect(assigns(:deploy).repo_id).to eq(101010)
        expect(response).to have_http_status(200)
      end

      it 'should create a deploy without a deployed_at because nil time turns into current time' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "sportngin/ngin",
                       "deployed_at" => nil,
                       "deployed_by" => "emmasax1"})
        expect(assigns(:deploy).git_revision).to eq("c1a2b37")
        expect(assigns(:deploy).deployed_by).to eq("emmasax1")
        expect(assigns(:deploy).repo_id).to eq(101010)
        expect(response).to have_http_status(200)
      end

      it 'should NOT create a deploy without a git_revision' do
        post(:create, {"git_revision" => nil,
                       "repo_name" => "sportngin/ngin",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "deployed_by" => "emmasax1"})
        expect(response).to have_http_status(400)
      end

      it 'should NOT create a deploy without a deployed_by' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "sportngin/ngin",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "deployed_by" => nil})
        expect(response).to have_http_status(400)
      end

      it 'should NOT create a deploy without a repo_name' do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => nil,
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "deployed_by" => "emmasax1"})
        expect(response).to have_http_status(400)
      end
    end

    describe "#index" do

      before :each do
        create(:repo, :full_name => "sportngin/ngin")
      end

      it "should correctly order all of the deploys" do
        post(:create, {"git_revision" => "c1a2b37",
                       "repo_name" => "sportngin/ngin",
                       "deployed_at" => "2009-02-03 03:00:00 -0500",
                       "deployed_by" => "emmasax1"})
        post(:create, {"git_revision" => "kd9c102",
                       "repo_name" => "sportngin/ngin",
                       "deployed_at" => "2015-02-03 03:00:00 -0500",
                       "deployed_by" => "emmasax1"})
        post(:create, {"git_revision" => "owk19sf",
                       "repo_name" => "sportngin/ngin",
                       "deployed_at" => "2011-02-03 03:00:00 -0500",
                       "deployed_by" => "emmasax1"})
        get :index
        expect(response).to have_http_status(200)
        expect(response).to render_template(:index)
      end
    end
  end
end
