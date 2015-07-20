class AddTeamIdToPrs < ActiveRecord::Migration
  def change
    add_column :hubstats_pull_requests, :team_id, :integer
  end
end
