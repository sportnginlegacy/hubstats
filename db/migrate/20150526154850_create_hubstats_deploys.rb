class CreateHubstatsDeploys < ActiveRecord::Migration
  def change
    create_table :hubstats_deploys do |t|
      t.string :git_revision
      t.string :repo_name
      t.timestamp :deployed_at
      t.string :deployed_by
      t.integer :repo_id
    end
  end
end
