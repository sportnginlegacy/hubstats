class AddDeployColumnToPullrequest < ActiveRecord::Migration[4.2.10]
  def change
  	add_column :hubstats_pull_requests, :deploy_id, :integer
  end
end
