require 'spec_helper'

module Hubstats
  describe User, :type => :model do
    before do
      Hubstats::User.destroy_all()
    end

    it 'creates and returns a user' do
      user = build(:user_hash, id: 10)
      expect(Hubstats::User.create_or_update(user).id).to eq(10)
    end

    it 'it updates a user based off id' do
      user1 = Hubstats::User.create_or_update(build(:user_hash, login: 'johnappleseed', id: 10))
      user2 = Hubstats::User.create_or_update(build(:user_hash, login: 'elliothursh', id: 10))
      expect(user1).to eq(user2)
    end
  end
end
