require 'spec_helper'

module Hubstats
  describe User, :type => :model do
    before do
      User.destroy_all()
    end

    it 'should create and return a user' do
      user = create(:user_hash, id: 10, :created_at => Date.today, :updated_at => Date.today)
      expect(User.create_or_update(user).id).to eq(10)
    end

    it 'should update a user based off id' do
      user1 = User.create_or_update(create(:user_hash, login: 'johnappleseed', id: 10, :created_at => Date.today, :updated_at => Date.today))
      user2 = User.create_or_update(create(:user_hash, login: 'johndoe', id: 10, :created_at => Date.today, :updated_at => Date.today))
      expect(user1).to eq(user2)
      expect(user2.login).to eq("johndoe")
      expect(user1.login).not_to eq("johnapplesdeed")
    end

    it 'should find the team that this user belongs to' do
      team = create(:team)
      user = create(:user, login: 'janedoe', id: 11, :created_at => Date.today, :updated_at => Date.today)
      team.users << user
      expect(user.login).to eq('janedoe')
      expect(user.team).to eq(team)
    end

    it 'should find first team that this user belongs to' do
      team1 = create(:team, name: "sad")
      team2 = create(:team, name: "happy")
      user = create(:user, login: 'janedoe', id: 11, :created_at => Date.today, :updated_at => Date.today)
      team1.users << user
      team2.users << user
      expect(user.login).to eq('janedoe')
      expect(user.team).to eq(team1)
    end

    it 'should return no team if the hubstats bool is false' do
      team = create(:team, hubstats: false)
      user = create(:user, login: 'janedoe', id: 11, :created_at => Date.today, :updated_at => Date.today)
      team.users << user
      expect(user.login).to eq('janedoe')
      expect(user.team).to eq(nil)
    end
  end
end
