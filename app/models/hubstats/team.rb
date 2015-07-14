module Hubstats
  class Team < ActiveRecord::Base

    scope :with_id, lambda {|team_id| where(id: team_id.split(',')) if team_id}

    # Public - Counts all of the users that are a part of the selected team.
    #
    # start_date - the start of the date range
    # end_date - the end of the date range
    #
    # Returns - the count of users
    scope :users_count, lambda {|start_date, end_date|
      select("hubstats_teams.id as team_id")
       .select("COUNT(hubstats_teams_users.user_id) AS user_count")
       .joins(:users)
       .group("hubstats_teams.id")
    }

    # Public - Counts all of the comments a selected team's members have written that occurred between the start_date and end_date.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # user_id_array - an array of all of the user ids in selected team
    # 
    # Returns - count of comments
    scope :comments_count, lambda {|start_date, end_date|
      select("IFNULL(COUNT(DISTINCT hubstats_comments.id),0) AS comment_count, hubstats_teams.id as team_id")
       .joins("LEFT OUTER JOIN hubstats_teams_users ON hubstats_teams.id = hubstats_teams_users.team_id")
       .joins(sanitize_sql_array(["LEFT JOIN hubstats_comments ON (hubstats_comments.user_id = hubstats_teams_users.user_id) AND (hubstats_comments.created_at BETWEEN ? AND ?)", start_date, end_date]))
       .group("hubstats_teams.id")
    }

    # Public - Counts all of the repos a selected team's members have made PRs or comments on.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - count of repos
    scope :repos_count, lambda {|start_date, end_date|
      select("hubstats_teams.id as team_id")
       .select("IFNULL(COUNT(DISTINCT hubstats_pull_requests.repo_id),0) AS repo_count")
       .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.team_id = hubstats_teams.id AND (hubstats_pull_requests.merged_at BETWEEN ? AND ?) AND hubstats_pull_requests.merged = '1'", start_date, end_date]))
       .group("hubstats_teams.id")
    }

    # Public - Counts all of the merged pull requests for selected team's users that occurred between the start_date and end_date.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - count of pull requests
    scope :pull_requests_count, lambda {|start_date, end_date|
      select("hubstats_teams.id as team_id")
      .select("IFNULL(COUNT(DISTINCT hubstats_pull_requests.id),0) AS pull_request_count")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.team_id = hubstats_teams.id AND (hubstats_pull_requests.merged_at BETWEEN ? AND ?) AND hubstats_pull_requests.merged = '1'", start_date, end_date]))
      .group("hubstats_teams.id")
    }

    # Public - Counts all of the addtiions and deletions made from PRs by a member of the selected team that have been merged between the start_date
    # and the end_date.
    #
    # start_date - the start of the date range
    # end_date - the end of the data range
    #
    # Returns - the additions and deletions
    scope :net_additions_count, lambda {|start_date, end_date|
      select("hubstats_teams.id as team_id")
      .select("SUM(IFNULL(hubstats_pull_requests.additions, 0)) AS additions")
      .select("SUM(IFNULL(hubstats_pull_requests.deletions, 0)) AS deletions")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.team_id = hubstats_teams.id AND (hubstats_pull_requests.merged_at BETWEEN ? AND ?) AND hubstats_pull_requests.merged = '1'", start_date, end_date]))
      .group("hubstats_teams.id")
    }

    # Public - Joins all of the metrics together for selected team: net additions, comments, repos, pull requests, and users.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # 
    # Returns - all of the stats about the team
    scope :with_all_metrics, lambda {|start_date, end_date|
      select("hubstats_teams.*, user_count, pull_request_count, comment_count, repo_count,additions, deletions")
       .joins("LEFT JOIN (#{net_additions_count(start_date, end_date).to_sql}) AS net_additions ON net_additions.team_id = hubstats_teams.id")
       .joins("LEFT JOIN (#{pull_requests_count(start_date, end_date).to_sql}) AS pull_requests ON pull_requests.team_id = hubstats_teams.id")
       .joins("LEFT JOIN (#{comments_count(start_date, end_date).to_sql}) AS comments ON comments.team_id = hubstats_teams.id")
       .joins("LEFT JOIN (#{repos_count(start_date, end_date).to_sql}) AS repos ON repos.team_id = hubstats_teams.id")
       .joins("LEFT JOIN (#{users_count(start_date, end_date).to_sql}) AS users ON users.team_id = hubstats_teams.id")
       .group("hubstats_teams.id")
    }

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


    # Public - Designed so that the list of teams can be ordered based on users, pulls, comments, net additions, or name.
    # if none of these are selected, then the default is to order by pull request count in descending order.
    #
    # order_params - the param of what the teams should be sorted by
    #
    # Returns - the team data ordered
    def self.custom_order(order_params)
      if order_params
        order = order_params.include?('asc') ? "ASC" : "DESC"
        case order_params.split('-').first
        when 'usercount'
          order("user_count #{order}")
        when 'pulls'
          order("pull_request_count #{order}")
        when 'comments'
          order("comment_count #{order}")
        when 'netadditions'
          order("additions - deletions #{order}")
        when 'repocount'
          order("repos_count #{order}")
        when 'name'
          order("name #{order}")
        else
          order("pull_request_count #{order}")
        end
      else 
        order("pull_request_count DESC")
      end
    end

    # Public - Designed to make a path for the show page when a team is selected.
    #
    # Returns - the show page of self.name
    # def to_param
    #   self.name
    # end

  end
end
