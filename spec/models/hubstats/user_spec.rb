require 'spec_helper'

module Hubstats
  describe User, :type => :model do

    before do
      Hubstats::User.destroy_all()
    end

    github_user1 = {
      :login => "elliothursh",
      :id => 10,
      :type => "User"
    }
    github_user2 = {
      :login => "johnappleseed",
      :id => 10,
      :type => "User"
    }

    it 'creates and returns a user' do
      user = Hubstats::User.create_or_update_user(github_user1)
      expect(user.id).to eq(10)
    end

    it 'finds and returns an existing user' do
      user1 = Hubstats::User.create_or_update_user(github_user1)
      user2 = Hubstats::User.create_or_update_user(github_user2)
      expect(user2.login).to eq('elliothursh')
    end

  end
end
