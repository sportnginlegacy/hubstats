module Hubification
  class PullRequest < ActiveRecord::Base
    attr_accessible :url, :html_url, :diff_url, :patch_url, :issue_url, :commits_url,
      :review_comments_url, :review_comment_url, :comments_url, :statuses_url, :number,
      :state, :title, :body, :created_at, :updated_at, :closed_at, :merged_at, 
      :merge_commit_sha, :merged, :mergeable, :comments, :commits, :additions,
      :deletions, :changed_files

      belongs_to :user
      belongs_to :merged_by, :class_name => "User", :foreign_key => "id"

  end
end
