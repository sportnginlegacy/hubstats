class CreateHubstatsPullRequests < ActiveRecord::Migration
  def change
    create_table :hubstats_pull_requests do |t|
      t.integer :id
      t.string :url
      t.string :html_url
      t.string :diff_url
      t.string :patch_url
      t.string :issue_url
      t.string :commits_url
      t.string :review_comments_url
      t.string :review_comment_url
      t.string :comments_url
      t.string :statuses_url
      t.integer :number
      t.string :state
      t.string :title
      t.string :body
      t.string :created_at
      t.string :updated_at
      t.string :closed_at
      t.string :merged_at
      t.string :merge_commit_sha
      t.string :merged
      t.string :mergeable
      t.integer :comments
      t.integer :commits
      t.integer :additions
      t.integer :deletions
      t.integer :changed_files
      t.belongs_to :user
      t.belongs_to :merged_by
      t.timestamps
    end
  end
end
