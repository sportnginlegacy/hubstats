class CreateHubstatsTeamsUsers < ActiveRecord::Migration
  def change
    create_table :hubstats_teams_users do |t|
      t.integer :user_id
      t.integer :team_id
    end
  end
end
