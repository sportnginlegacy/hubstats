class CreateHubstatsComments < ActiveRecord::Migration
  def change
    create_table :hubstats_comments do |t|
      t.integer :id
      t.string :html_url
      t.string :url
      t.string :pull_request_url
      t.string :diff_hunk
      t.integer :path
      t.integer :position
      t.string :original_position
      t.string :line
      t.string :commit_id
      t.string :original_commit_id
      t.string :body
      t.belongs_to :user
      t.timestamps
    end
  end
end
