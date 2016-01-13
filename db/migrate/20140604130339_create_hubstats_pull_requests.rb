class CreateHubstatsPullRequests < ActiveRecord::Migration
  def change
    create_table :hubstats_pull_requests do |t|
      t.integer :number
      t.belongs_to :user
      t.belongs_to :repo
      t.datetime :created_at
      t.datetime :updated_at
      t.datetime :closed_at
      t.integer :additions
      t.integer :deletions
      t.integer :comments
      t.integer :commits
      t.integer :changed_files

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
      t.string :state
      t.string :title
      t.string :body
      t.string :merged_at
      t.string :merge_commit_sha
      t.string :merged
      t.string :mergeable
    end

    add_index :hubstats_pull_requests, :user_id
    add_index :hubstats_pull_requests, :repo_id
  end
end
