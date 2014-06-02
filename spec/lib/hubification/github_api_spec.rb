require 'spec_helper'

module Hubification
  describe GithubAPI, :type => :model do

    it 'should have the client.user.login be elliothursh' do
      client = Hubification::GithubAPI.client

      expect(client.user.login).to eq('elliothursh')
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
