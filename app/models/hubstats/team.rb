module Hubstats
  class Team < ActiveRecord::Base

    attr_accessible :name, :description, :hubstats
    has_and_belongs_to_many :users, :join_table => 'hubstats_teams_users'

    # Public - Checks if the team is currently existing, and if it isn't, then makes a new team with 
    # the specifications that are passed in. We are assuming that if it is not already existent,
    # then we probably don't really care about the team, so our hubstats boolean will be set to false.
    #
    # team - the info that's passed in about the new team
    #
    # Returns - the team 
    def self.first_or_create(team)
      if exists = Hubstats::Team.where(name: team[:name]).first
        return exists
      else
        Team.new(name: team[:name], description: team[:description], hubstats: false)
      end
    end

  end
end
