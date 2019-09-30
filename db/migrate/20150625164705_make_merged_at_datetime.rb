class MakeMergedAtDatetime < ActiveRecord::Migration[4.2.10]
  def change
    remove_column :hubstats_pull_requests, :merged_at
    add_column :hubstats_pull_requests, :merged_at, :datetime
  end
end
