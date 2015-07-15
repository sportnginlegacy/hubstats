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
  end
end
