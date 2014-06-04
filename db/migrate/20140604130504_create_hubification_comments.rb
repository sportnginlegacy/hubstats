class CreateHubificationComments < ActiveRecord::Migration
  def change
    create_table :hubification_comments do |t|
      t.integer :id
      t.string :html_url
      t.string :url
      t.string :pull_request_url
      t.string :diff_hunk
      t.string :path
      t.string :position
      t.string :original_position
      t.string :line
      t.string :commit_id
      t.string :original_commit_id
      t.string :body
      t.timestamps
    end
  end
end
