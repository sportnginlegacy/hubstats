class CreateHubstatsDeploys < ActiveRecord::Migration['4.2.10']
  def change
    create_table :hubstats_deploys do |t|
      t.string :git_revision
      t.integer :repo_id
      t.timestamp :deployed_at
      t.string :deployed_by
    end
  end
end
