class CreateHubstatsLabelsPullRequests < ActiveRecord::Migration
  def change
    create_table :hubstats_labels_pull_requests do |t|
      t.belongs_to :pull_request
      t.belongs_to :label
    end
  end
end
