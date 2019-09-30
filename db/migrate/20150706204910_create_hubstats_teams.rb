class CreateHubstatsTeams < ActiveRecord::Migration[4.2.10]
  def change
    create_table :hubstats_teams do |t|
      t.string :name
      t.boolean :hubstats
    end
  end
end
