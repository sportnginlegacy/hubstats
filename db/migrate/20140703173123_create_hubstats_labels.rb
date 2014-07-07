class CreateHubstatsLabels < ActiveRecord::Migration
  def change
    create_table :hubstats_labels do |t|
      t.string :name
      t.string :color
      t.string :url
    end
  end
end
