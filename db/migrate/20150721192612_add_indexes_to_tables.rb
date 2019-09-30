class AddIndexesToTables < ActiveRecord::Migration[4.2.10]
  def change
    add_index :hubstats_deploys, :repo_id
    add_index :hubstats_deploys, :user_id

    add_index :hubstats_labels_pull_requests, :pull_request_id
    add_index :hubstats_labels_pull_requests, :label_id

    add_index :hubstats_pull_requests, :deploy_id
    add_index :hubstats_pull_requests, :team_id

    add_index :hubstats_teams_users, :user_id
    add_index :hubstats_teams_users, :team_id
  end
end
