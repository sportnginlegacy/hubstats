class CreateHubstatsRepos < ActiveRecord::Migration[4.2]
  def change
    create_table :hubstats_repos do |t|
      t.belongs_to :owner
      t.string :name
      t.string :full_name
      t.datetime :pushed_at
      t.datetime :created_at
      t.datetime :updated_at

      t.string :homepage
      t.string :language
      t.integer :forks_count
      t.integer :stargazers_count
      t.integer :watches_count
      t.integer :size
      t.integer :open_issues_count
      t.boolean :has_issues
      t.boolean :has_wiki
      t.boolean :has_downloads
      t.boolean :private
      t.boolean :fork
      t.string :description
      t.string :default_branch
      t.string :url
      t.string :html_url
      t.string :clone_url
      t.string :git_url
      t.string :ssh_url
      t.string :svn_url
      t.string :mirror_url
      t.string :hooks_url
      t.string :issue_events_url
      t.string :events_url
      t.string :contributors_url
      t.string :git_commits_url
      t.string :issue_comment_url
      t.string :merges_url
      t.string :issues_url
      t.string :pulls_url
      t.string :labels_url
    end

     add_index :hubstats_repos, :owner_id
  end
end
