class AddMergedByColumnToPullRequest < ActiveRecord::Migration
  def change
  	add_column :hubstats_pull_requests, :merged_by, :integer
  end
end
