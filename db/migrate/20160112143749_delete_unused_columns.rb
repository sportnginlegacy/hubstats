class DeleteUnusedColumns < ActiveRecord::Migration[4.2.10]
  def change
  	remove_column :hubstats_comments, :line
  	remove_column :hubstats_comments, :diff_hunk
  	remove_column :hubstats_comments, :position
  	remove_column :hubstats_comments, :original_position
  	remove_column :hubstats_comments, :commit_id
  	remove_column :hubstats_comments, :original_commit_id

  	remove_column :hubstats_pull_requests, :commits
  	remove_column :hubstats_pull_requests, :changed_files
  	remove_column :hubstats_pull_requests, :patch_url
  	remove_column :hubstats_pull_requests, :diff_url
  	remove_column :hubstats_pull_requests, :commits_url
  	remove_column :hubstats_pull_requests, :review_comments_url
  	remove_column :hubstats_pull_requests, :review_comment_url
  	remove_column :hubstats_pull_requests, :comments_url
  	remove_column :hubstats_pull_requests, :statuses_url
  	remove_column :hubstats_pull_requests, :body
  	remove_column :hubstats_pull_requests, :merge_commit_sha
  	remove_column :hubstats_pull_requests, :mergeable

  	remove_column :hubstats_repos, :homepage
  	remove_column :hubstats_repos, :language
  	remove_column :hubstats_repos, :forks_count
  	remove_column :hubstats_repos, :stargazers_count
  	remove_column :hubstats_repos, :watches_count
  	remove_column :hubstats_repos, :size
  	remove_column :hubstats_repos, :open_issues_count
  	remove_column :hubstats_repos, :has_issues
  	remove_column :hubstats_repos, :has_wiki
  	remove_column :hubstats_repos, :has_downloads
  	remove_column :hubstats_repos, :private
  	remove_column :hubstats_repos, :fork
  	remove_column :hubstats_repos, :description
  	remove_column :hubstats_repos, :default_branch
  	remove_column :hubstats_repos, :clone_url
  	remove_column :hubstats_repos, :git_url
  	remove_column :hubstats_repos, :ssh_url
  	remove_column :hubstats_repos, :svn_url
  	remove_column :hubstats_repos, :mirror_url
  	remove_column :hubstats_repos, :hooks_url
  	remove_column :hubstats_repos, :issue_events_url
  	remove_column :hubstats_repos, :events_url
  	remove_column :hubstats_repos, :contributors_url
  	remove_column :hubstats_repos, :git_commits_url
  	remove_column :hubstats_repos, :issue_comment_url
  	remove_column :hubstats_repos, :merges_url
  	remove_column :hubstats_repos, :issues_url
  	remove_column :hubstats_repos, :pulls_url

  	remove_column :hubstats_users, :site_admin
  	remove_column :hubstats_users, :gravatar_id
  	remove_column :hubstats_users, :followers_url
  	remove_column :hubstats_users, :following_url
  	remove_column :hubstats_users, :gists_url
  	remove_column :hubstats_users, :starred_url
  	remove_column :hubstats_users, :subscriptions_url
  	remove_column :hubstats_users, :organizations_url
  	remove_column :hubstats_users, :repos_url
  	remove_column :hubstats_users, :events_url
  	remove_column :hubstats_users, :received_events_url
  end
end
