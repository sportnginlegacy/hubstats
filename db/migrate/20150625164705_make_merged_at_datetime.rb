class MakeMergedAtDatetime < ActiveRecord::Migration
  def change
    remove_column :hubstats_pull_requests, :merged_at
    add_column :hubstats_pull_requests, :merged_at, :datetime
  end
end
