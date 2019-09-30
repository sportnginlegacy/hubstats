class AddMergedByColumnToPullRequest < ActiveRecord::Migration[4.2]
  def change
  	add_column :hubstats_pull_requests, :merged_by, :integer
  end
end
