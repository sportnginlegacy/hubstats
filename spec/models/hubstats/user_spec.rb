require 'spec_helper'

module Hubstats
  describe User, :type => :model do
    before do
      User.destroy_all()
    end

    it 'should create and return a user' do
      user = build(:user_hash, id: 10)
      expect(User.create_or_update(user).id).to eq(10)
    end

    it 'should update a user based off id' do
      user1 = User.create_or_update(build(:user_hash, login: 'johnappleseed', id: 10))
      user2 = User.create_or_update(build(:user_hash, login: 'johndoe', id: 10))
      expect(user1).to eq(user2)
      expect(user2.login).to eq("johndoe")
      expect(user1.login).not_to eq("johnapplesdeed")
    end
  end
end
