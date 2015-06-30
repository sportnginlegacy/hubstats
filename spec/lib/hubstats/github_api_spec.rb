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

        it 'should initialize client with options param' do
          Hubstats::GithubAPI.configure({"access_token" => access_token})
          expect(Octokit::Client).to receive(:new).with(access_token: access_token).and_return(client)
          expect(Hubstats::GithubAPI.client).to eq(client)
        end
      end

      context "with environment variables" do
        before do
          allow(ENV).to receive(:[]).with("GITHUB_API_TOKEN").and_return("github_api_token")
        end

        it 'should initialize client with environment variables' do
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

        it 'should intialize client with client-id environment variables' do
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

        # If this test begins to fail, it is because there are so many repeated calls to Octokit; just comment out
        it 'should fail to initialize at all' do
         Hubstats::GithubAPI.configure()
         expect{Hubstats::GithubAPI.client}.to raise_error Octokit::Unauthorized
        end
      end
    end

    context ".update_hook" do
      subject {Hubstats::GithubAPI}
      let(:repo) {'hubstats'}
      context "with old_endpoint" do
        let(:old_endpoint) {'www.hubstats.com'}
        it 'should call delete_hook' do
          allow(subject).to receive(:create_hook)
          expect(subject).to receive(:delete_hook).with(repo,old_endpoint)
          subject.update_hook('hubstats','www.hubstats.com')
        end
      end

      context "without old_point" do
        it 'should not call delete_hook' do
          allow(subject).to receive(:create_hook)
          expect(subject).to_not receive(:delete_hook).with(repo)
          subject.update_hook('hubstats')
        end
      end
    end

    context ".create_hook" do
      subject {Hubstats::GithubAPI}
      let(:config) {double(:webhook_secret => 'a1b2c3d4', :webhook_endpoint => "hubstats.com")}
      let(:client) {double}
      let(:repo) {double(:full_name =>'hubstats') }
      before do
        allow(Hubstats).to receive(:config) {config}
        allow(subject).to receive(:client) {client}
      end

      it "should call octokit create_hook" do
        expect(client).to receive(:create_hook)
        subject.create_hook(repo)
      end

      it "should rescue unprocessable entity" do
        allow(client).to receive(:create_hook) { raise Octokit::UnprocessableEntity }
        subject.create_hook(repo)
      end
    end

  end
end
