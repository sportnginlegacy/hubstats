module Hubstats
  class Team < ActiveRecord::Base

    def self.record_timestamps; false; end

    scope :with_id, lambda {|team_id| where(id: team_id.split(',')) if team_id}

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

    # Public - Counts all of the merged pull requests for selected team's users that occurred between the start_date and end_date.
    #
    # start_date - the start of the date range
    # end_date - the end of the data range
    #
    # Returns - count of pull requests
    scope :pull_requests_count, lambda {|start_date, end_date|
      select("hubstats_teams.id as team_id")
      .select("IFNULL(COUNT(DISTINCT hubstats_pull_requests.id),0) AS pull_request_count")
      .joins(sanitize_sql_array(["LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.team_id = hubstats_teams.id AND (hubstats_pull_requests.merged_at BETWEEN ? AND ?) AND hubstats_pull_requests.merged = ?", start_date, end_date, true]))
      .group("hubstats_teams.id")
    }

    # Public - Joins all of the metrics together for selected team: net additions, comments, repos, and pull requests.
    #
    # start_date - the start of the date range
    # end_date - the end of the data range
    #
    # Returns - all of the stats about the team
    scope :with_all_metrics, lambda {|start_date, end_date|
      select("hubstats_teams.*, pull_request_count, comment_count")
       .joins("LEFT JOIN (#{pull_requests_count(start_date, end_date).to_sql}) AS pull_requests ON pull_requests.team_id = hubstats_teams.id")
       .joins("LEFT JOIN (#{comments_count(start_date, end_date).to_sql}) AS comments ON comments.team_id = hubstats_teams.id")
       .group("hubstats_teams.id")
    }

    has_and_belongs_to_many :users, :join_table => 'hubstats_teams_users', :uniq => true

    def designed_for_hubstats?(description)
      description.include?("hubstats") ||
      description.include?("Hubstats") ||
      description.include?("hub") ||
      description.include?("Hub")
    end

    # Public - Checks if the team is currently existing, and if it isn't, then makes a new team with
    # the specifications that are passed in. We are assuming that if it is not already existent,
    # then we probably don't really care about the team, so our hubstats boolean will be set to false.
    #
    # github_team - the info that's passed in about the new or updated team
    #
    # Returns - the team
    def self.create_or_update(github_team)
      github_team = github_team.to_h.with_indifferent_access if github_team.respond_to? :to_h

      team_data = github_team.slice(*Hubstats::Team.column_names.map(&:to_sym))
      team = where(:id => team_data[:id]).first_or_create(team_data)

      team_data[:hubstats] = true

      return team if team.update_attributes(team_data)
      Rails.logger.warn team.errors.inspect
    end

    # Public - Adds or removes a user from a team
    #
    # team - a hubstats team that we wish to edit the users of
    # user - a hubstats user that we wish to remove or add to the team
    # action - whether the user is to be removed or added (string)
    #
    # Returns - nothing
    def self.update_users_in_team(team, user, action)
      if action == "added"
        team.users << user
      elsif action == "removed"
        team.users.delete(user)
      end
      team.save!
    end

    # Public - Orders the list of data by name (alphabetical)
    #
    # Returns - the data ordered alphabetically by name
    def self.order_by_name
      order("name ASC")
    end
  end
end
