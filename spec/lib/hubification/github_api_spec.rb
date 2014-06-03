require 'spec_helper'

module Hubification
  describe GithubAPI, :type => :model do
    context ".configure" do
      let(:access_token) { "access_token" }
      let(:user) { double }
      let(:client) { double(:user => user) }

      before do
        allow(client).to receive(:user).and_return( "user" )
      end

      context "Config File" do
        before do
          allow(ENV).to receive(:[]).and_return(nil)
        end

        it 'should intialize with options param' do
          expect(Octokit::Client).to receive(:new).with(access_token: access_token).and_return(client)
          expect(Hubification::GithubAPI.configure({"access_token" => access_token})).to eq(client)
        end
      end

      context "environment variables" do
        before do
          allow(ENV).to receive(:[]).with("GITHUB_API_TOKEN").and_return("github_api_token")
        end

        it 'should initialize env instead of options param' do
          expect(Octokit::Client).to receive(:new).with(access_token: "github_api_token").and_return(client)
          expect(Hubification::GithubAPI.configure({"access_token" => access_token})).to eq(client)
        end
      end

      context "application authentication" do 
        before do 
          allow(ENV).to receive(:[]).and_return(nil)
          allow(ENV).to receive(:[]).with("CLIENT_ID").and_return("client_id")
          allow(ENV).to receive(:[]).with("CLIENT_SECRET").and_return("client_secret")
        end 

        it 'should intialize properly' do
          expect(Octokit::Client).to receive(:new).with(client_id: "client_id", client_secret: "client_secret").and_return(client)
          expect(Hubification::GithubAPI.configure({"client_id" => "client_id", "client_secret" => "client_secret"})).to eq(client)
        end
      end

      context "improperly" do
        before do
          allow(ENV).to receive(:[]).and_return(nil)
        end

        it 'should not initialize at all'  do
          expect(lambda { Hubification::GithubAPI.configure()}).to raise_error GithubAPI::InvalidLogin 
        end
      end

    end

    context ".since" do
      let(:client) { double }
      let(:pull1) { double }
      let(:pull2) { double }
      let(:pull_requests) { [pull1, pull2] }

      before do
        allow(GithubAPI).to receive(:client).and_return(client)
        allow(client).to receive(:paginate).and_return(pull_requests)
        allow(pull1).to receive(:closed_at).and_return(Time.new(2014,05,25).to_datetime)
        allow(pull2).to receive(:closed_at).and_return(Time.new(2014,05,20).to_datetime)
      end

      it 'should get more requests for the earlier date' do

        client = Hubification::GithubAPI.client
        earlier = Time.new(2014,05,18).to_datetime
        later = Time.new(2014,05,23).to_datetime

        earlier_pulls = Hubification::GithubAPI.since(earlier)
        later_pulls = Hubification::GithubAPI.since(later)

        expect(earlier_pulls.length).to be > later_pulls.length
      end

      context "multiple pages" do
        let(:pr_num1) { Array.new(30, pull1) }
        let(:pr_num2) { Array.new(10, pull2) }

        before do
          allow(client).to receive(:paginate).and_return(pr_num1, pr_num2)
        end

        it 'should get 40 pulls' do 
          client = Hubification::GithubAPI.client
          datetime = Time.new(2014,05,18).to_datetime

          pulls = Hubification::GithubAPI.since(datetime)

          expect(pulls.length).to eq(40)
        end
      end   
    end

  end
end
