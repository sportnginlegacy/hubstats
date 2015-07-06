module Hubstats
  class Team < ActiveRecord::Base

    attr_accessible :name, :description, :hubstats
    has_and_belongs_to_many :users, :join_table => 'hubstats_teams_users'

  end
end
