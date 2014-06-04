class CreateHubificationRepos < ActiveRecord::Migration
  def change
    create_table :hubification_repos do |t|

      t.timestamps
    end
  end
end
