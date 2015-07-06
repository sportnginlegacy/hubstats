class CreateHubstatsTeams < ActiveRecord::Migration
  def change
    create_table :hubstats_teams do |t|
      t.string :name
      t.string :description
      t.boolean :hubstats
    end
  end
end
