module Hubstats
  class Team < ActiveRecord::Base

    scope :with_id, lambda {|user_id| where(id: user_id.split(',')) if user_id}

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

    # Public - Designed so that the list of users can be ordered based on deploys, pulls, comments, net additions, or name.
    # if none of these are selected, then the default is to order by pull request count in descending order.
    #
    # order_params - the param of what the users should be sorted by
    #
    # Returns - the user data ordered
    def self.custom_order(order_params)
      if order_params
        order = order_params.include?('asc') ? "ASC" : "DESC"
        case order_params.split('-').first
        when 'deploys'
          order("deploy_count #{order}")
        when 'pulls'
          order("pull_request_count #{order}")
        when 'comments'
          order("comment_count #{order}")
        when 'netadditions'
          order("additions - deletions #{order}")
        when 'name'
          order("login #{order}")
        else
          order("pull_request_count #{order}")
        end
      else 
        order("pull_request_count DESC")
      end
    end

  end
end
