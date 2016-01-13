class CreateHubstatsComments < ActiveRecord::Migration
  def change
    create_table :hubstats_comments do |t|
      t.string :kind
      t.belongs_to :user
      t.belongs_to :pull_request
      t.belongs_to :repo
      t.datetime :created_at
      t.datetime :updated_at
      t.string :body

      t.string :diff_hunk
      t.integer :path
      t.integer :position
      t.string :original_position
      t.string :line
      t.string :commit_id
      t.string :original_commit_id

      t.string :html_url
      t.string :url
      t.string :pull_request_url
    end

    add_index :hubstats_comments, :user_id
    add_index :hubstats_comments, :pull_request_id
  end
end
