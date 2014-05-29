require 'spec_helper'
require_relative "../../../lib/hubification/github_api"

module Hubification
  describe GithubAPI, :type => :model do
    it 'should have the client.user.login be elliothursh' do
      client = Hubification::GithubAPI.client

      expect(client.user.login).to eq('elliothursh')
    end

    it 'should get more requests for the earlier date' do
      client = Hubification::GithubAPI.client
      earlier = "2014-05-18T19:01:12Z".to_datetime
      later = "2014-05-25T19:01:12Z".to_datetime

      earlier_pulls = Hubification::GithubAPI.since(earlier)
      later_pulls = Hubification::GithubAPI.since(later)

      expect(earlier_pulls.length).to be > later_pulls.length
    end

  end
end
