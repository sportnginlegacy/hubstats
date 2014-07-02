require 'spec_helper'

module Hubstats
  describe GithubAPI, :type => :model do
    context ".configure" do
      let(:access_token) { "access_token" }
      let(:user) { double }
      let(:client) { double(:user => user) }

      before do
        allow(client).to receive(:user).and_return( "user" )
      end

      after do
        puts Hubstats::GithubAPI.class_variable_set(:@@auth_info, nil)
      end

      context "with configuration file" do
        before do
          allow(ENV).to receive(:[]).and_return(nil)
        end

        it 'initializes client with options param' do
          Hubstats::GithubAPI.configure({"access_token" => access_token})
          expect(Octokit::Client).to receive(:new).with(access_token: access_token).and_return(client)
          expect(Hubstats::GithubAPI.client).to eq(client)
        end
      end

      context "with environment variables" do
        before do
          allow(ENV).to receive(:[]).with("GITHUB_API_TOKEN").and_return("github_api_token")
        end

        it 'initializes client with environment variables' do
          Hubstats::GithubAPI.configure({"access_token" => access_token})
          expect(Octokit::Client).to receive(:new).with(access_token: "github_api_token").and_return(client)
          expect(Hubstats::GithubAPI.client()).to eq(client)
        end
      end

      context "with application authentication" do 
        before do 
          allow(ENV).to receive(:[]).and_return(nil)
          allow(ENV).to receive(:[]).with("CLIENT_ID").and_return("client_id")
          allow(ENV).to receive(:[]).with("CLIENT_SECRET").and_return("client_secret")
        end 

        it 'intializes client with client-id environment variables' do
          Hubstats::GithubAPI.configure()
          expect(Octokit::Client).to receive(:new).with(client_id: "client_id", client_secret: "client_secret").and_return(client)
          expect(Hubstats::GithubAPI.client).to eq(client)
        end
      end

      context "with wrong credentials" do
        before do
          allow(client).to receive(:user).and_return( nil )
          allow(ENV).to receive(:[]).and_return(nil)
        end

        it 'fails to initialize at all' do
          Hubstats::GithubAPI.configure()
          expect(lambda { Hubstats::GithubAPI.client}).to raise_error Octokit::Unauthorized
        end
      end
    end

    # context ".update_pulls" do

    #   it 'catches error and continues'
    #     Hubstats::GithubAPI.update_pulls
    #   end
    # end
  end
end
