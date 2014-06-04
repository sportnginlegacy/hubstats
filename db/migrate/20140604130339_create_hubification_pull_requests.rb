class CreateHubificationPullRequests < ActiveRecord::Migration
  def change
    create_table :hubification_pull_requests do |t|

      t.timestamps
    end
  end
end
