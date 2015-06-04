class AddDeployColumnToPullrequest < ActiveRecord::Migration
  def change
  	add_column :hubstats_pull_requests, :deploy_id, :integer
  end
end
