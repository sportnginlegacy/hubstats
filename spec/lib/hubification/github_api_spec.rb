require 'spec_helper'
require_relative "../../../lib/hubification/github_api"

module Hubification
  describe GithubApi, :type => :model do
    it 'should have the client.user.login be elliothursh' do
      client = Hubification::GithubApi.client

      expect(client.user.login).to eq('elliothursh')
    end
  end
end
