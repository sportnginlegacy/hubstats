class CreateHubstatsTeams < ActiveRecord::Migration
  def change
    create_table :hubstats_teams do |t|
      t.string :name
      t.boolean :hubstats
    end
  end
end
