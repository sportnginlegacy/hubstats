class CreateHubstatsRepos < ActiveRecord::Migration
  def change
    create_table :hubstats_repos do |t|

      t.timestamps
    end
  end
end
