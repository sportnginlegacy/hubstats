require 'spec_helper'

module Hubstats
  describe Team, :type => :model do
    it 'should create a team' do
      team_hash = {name: "Team Tippy-Tappy-Toes",
                   hubstats: true}
      team = Team.create(team_hash)
      expect(Team.count).to eq(1)
      expect(team.name).to eq("Team Tippy-Tappy-Toes")
      expect(team.hubstats).to eq(true)
    end

    it 'should add a member to a team' do
      user = create(:user, :created_at => Date.today, :updated_at => Date.today)
      action = "added"
      team = create(:team)
      Hubstats::Team.update_users_in_team(team, user, action)
      expect(team.users).to eq([user])
      expect(team.users.length).to eq(1)
    end
  end
end
