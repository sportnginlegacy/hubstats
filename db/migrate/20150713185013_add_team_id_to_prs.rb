class AddTeamIdToPrs < ActiveRecord::Migration[4.2]
  def change
    add_column :hubstats_pull_requests, :team_id, :integer
  end
end
