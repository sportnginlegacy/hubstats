class AddUserIdDeleteDeployedByToDeploy < ActiveRecord::Migration[4.2]
  def change
    add_column :hubstats_deploys, :user_id, :integer
    remove_column :hubstats_deploys, :deployed_by
  end
end
