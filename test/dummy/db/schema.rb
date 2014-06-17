# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140604130550) do

  create_table "hubstats_comments", :force => true do |t|
    t.string   "html_url"
    t.string   "url"
    t.string   "pull_request_url"
    t.string   "diff_hunk"
    t.integer  "path"
    t.integer  "position"
    t.string   "original_position"
    t.string   "line"
    t.string   "commit_id"
    t.string   "original_commit_id"
    t.string   "body"
    t.integer  "user_id"
    t.integer  "pull_request_id"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "hubstats_comments", ["pull_request_id"], :name => "index_hubstats_comments_on_pull_request_id"
  add_index "hubstats_comments", ["user_id"], :name => "index_hubstats_comments_on_user_id"

  create_table "hubstats_pull_requests", :force => true do |t|
    t.string  "url"
    t.string  "html_url"
    t.string  "diff_url"
    t.string  "patch_url"
    t.string  "issue_url"
    t.string  "commits_url"
    t.string  "review_comments_url"
    t.string  "review_comment_url"
    t.string  "comments_url"
    t.string  "statuses_url"
    t.integer "number"
    t.string  "state"
    t.string  "title"
    t.string  "body"
    t.string  "created_at",          :null => false
    t.string  "updated_at",          :null => false
    t.string  "closed_at"
    t.string  "merged_at"
    t.string  "merge_commit_sha"
    t.string  "merged"
    t.string  "mergeable"
    t.integer "comments"
    t.integer "commits"
    t.integer "additions"
    t.integer "deletions"
    t.integer "changed_files"
    t.integer "user_id"
    t.integer "repo_id"
  end

  add_index "hubstats_pull_requests", ["repo_id"], :name => "index_hubstats_pull_requests_on_repo_id"
  add_index "hubstats_pull_requests", ["user_id"], :name => "index_hubstats_pull_requests_on_user_id"

  create_table "hubstats_repos", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "homepage"
    t.string   "language"
    t.string   "description"
    t.string   "default_branch"
    t.string   "url"
    t.string   "html_url"
    t.string   "clone_url"
    t.string   "git_url"
    t.string   "ssh_url"
    t.string   "svn_url"
    t.string   "mirror_url"
    t.string   "hooks_url"
    t.string   "issue_events_url"
    t.string   "events_url"
    t.string   "contributors_url"
    t.string   "git_commits_url"
    t.string   "issue_comment_url"
    t.string   "merges_url"
    t.string   "issues_url"
    t.string   "pulls_url"
    t.string   "labels_url"
    t.integer  "forks_count"
    t.integer  "stargazers_count"
    t.integer  "watches_count"
    t.integer  "size"
    t.integer  "open_issues_count"
    t.boolean  "has_issues"
    t.boolean  "has_wiki"
    t.boolean  "has_downloads"
    t.boolean  "private"
    t.boolean  "fork"
    t.datetime "pushed_at"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "owner_id"
  end

  add_index "hubstats_repos", ["owner_id"], :name => "index_hubstats_repos_on_owner_id"

  create_table "hubstats_users", :force => true do |t|
    t.string   "login"
    t.string   "avatar_url"
    t.string   "gravatar_id"
    t.string   "url"
    t.string   "html_url"
    t.string   "followers_url"
    t.string   "following_url"
    t.string   "gists_url"
    t.string   "starred_url"
    t.string   "subscriptions_url"
    t.string   "organizations_url"
    t.string   "repos_url"
    t.string   "events_url"
    t.string   "received_events_url"
    t.string   "role"
    t.boolean  "site_admin"
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

end
