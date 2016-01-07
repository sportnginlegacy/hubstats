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
# It's strongly recommended that you check this file into your version control system.

<<<<<<< Updated upstream
ActiveRecord::Schema.define(version: 20160106191751) do
=======
ActiveRecord::Schema.define(:version => 20160106191751) do
>>>>>>> Stashed changes

  create_table "hubstats_comments", force: :cascade do |t|
    t.string   "kind",               limit: 255
    t.integer  "user_id",            limit: 4
    t.integer  "pull_request_id",    limit: 4
    t.integer  "repo_id",            limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "body",               limit: 255
    t.string   "diff_hunk",          limit: 255
    t.integer  "path",               limit: 4
    t.integer  "position",           limit: 4
    t.string   "original_position",  limit: 255
    t.string   "line",               limit: 255
    t.string   "commit_id",          limit: 255
    t.string   "original_commit_id", limit: 255
    t.string   "html_url",           limit: 255
    t.string   "url",                limit: 255
    t.string   "pull_request_url",   limit: 255
  end

  add_index "hubstats_comments", ["pull_request_id"], name: "index_hubstats_comments_on_pull_request_id", using: :btree
  add_index "hubstats_comments", ["user_id"], name: "index_hubstats_comments_on_user_id", using: :btree

  create_table "hubstats_deploys", force: :cascade do |t|
    t.string   "git_revision", limit: 255
    t.integer  "repo_id",      limit: 4
    t.datetime "deployed_at"
    t.integer  "user_id",      limit: 4
  end

  add_index "hubstats_deploys", ["repo_id"], name: "index_hubstats_deploys_on_repo_id", using: :btree
  add_index "hubstats_deploys", ["user_id"], name: "index_hubstats_deploys_on_user_id", using: :btree

  create_table "hubstats_labels", force: :cascade do |t|
    t.string "name",  limit: 255
    t.string "color", limit: 255
    t.string "url",   limit: 255
  end

  create_table "hubstats_labels_pull_requests", force: :cascade do |t|
    t.integer "pull_request_id", limit: 4
    t.integer "label_id",        limit: 4
  end

  add_index "hubstats_labels_pull_requests", ["label_id"], name: "index_hubstats_labels_pull_requests_on_label_id", using: :btree
  add_index "hubstats_labels_pull_requests", ["pull_request_id"], name: "index_hubstats_labels_pull_requests_on_pull_request_id", using: :btree

  create_table "hubstats_pull_requests", force: :cascade do |t|
    t.integer  "number",              limit: 4
    t.integer  "user_id",             limit: 4
    t.integer  "repo_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer  "additions",           limit: 4
    t.integer  "deletions",           limit: 4
    t.integer  "comments",            limit: 4
    t.integer  "commits",             limit: 4
    t.integer  "changed_files",       limit: 4
    t.string   "url",                 limit: 255
    t.string   "html_url",            limit: 255
    t.string   "diff_url",            limit: 255
    t.string   "patch_url",           limit: 255
    t.string   "issue_url",           limit: 255
    t.string   "commits_url",         limit: 255
    t.string   "review_comments_url", limit: 255
    t.string   "review_comment_url",  limit: 255
    t.string   "comments_url",        limit: 255
    t.string   "statuses_url",        limit: 255
    t.string   "state",               limit: 255
    t.string   "title",               limit: 255
    t.string   "body",                limit: 255
    t.string   "merge_commit_sha",    limit: 255
    t.string   "merged",              limit: 255
    t.string   "mergeable",           limit: 255
    t.integer  "deploy_id",           limit: 4
    t.integer  "merged_by",           limit: 4
    t.datetime "merged_at"
    t.integer  "team_id",             limit: 4
  end

  add_index "hubstats_pull_requests", ["deploy_id"], name: "index_hubstats_pull_requests_on_deploy_id", using: :btree
  add_index "hubstats_pull_requests", ["repo_id"], name: "index_hubstats_pull_requests_on_repo_id", using: :btree
  add_index "hubstats_pull_requests", ["team_id"], name: "index_hubstats_pull_requests_on_team_id", using: :btree
  add_index "hubstats_pull_requests", ["user_id"], name: "index_hubstats_pull_requests_on_user_id", using: :btree

  create_table "hubstats_repos", force: :cascade do |t|
    t.integer  "owner_id",          limit: 4
    t.string   "name",              limit: 255
    t.string   "full_name",         limit: 255
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "homepage",          limit: 255
    t.string   "language",          limit: 255
    t.integer  "forks_count",       limit: 4
    t.integer  "stargazers_count",  limit: 4
    t.integer  "watches_count",     limit: 4
    t.integer  "size",              limit: 4
    t.integer  "open_issues_count", limit: 4
    t.boolean  "has_issues"
    t.boolean  "has_wiki"
    t.boolean  "has_downloads"
    t.boolean  "private"
    t.boolean  "fork"
    t.string   "description",       limit: 255
    t.string   "default_branch",    limit: 255
    t.string   "url",               limit: 255
    t.string   "html_url",          limit: 255
    t.string   "clone_url",         limit: 255
    t.string   "git_url",           limit: 255
    t.string   "ssh_url",           limit: 255
    t.string   "svn_url",           limit: 255
    t.string   "mirror_url",        limit: 255
    t.string   "hooks_url",         limit: 255
    t.string   "issue_events_url",  limit: 255
    t.string   "events_url",        limit: 255
    t.string   "contributors_url",  limit: 255
    t.string   "git_commits_url",   limit: 255
    t.string   "issue_comment_url", limit: 255
    t.string   "merges_url",        limit: 255
    t.string   "issues_url",        limit: 255
    t.string   "pulls_url",         limit: 255
    t.string   "labels_url",        limit: 255
  end

  add_index "hubstats_repos", ["owner_id"], name: "index_hubstats_repos_on_owner_id", using: :btree

  create_table "hubstats_teams", force: :cascade do |t|
    t.string  "name",     limit: 255
    t.boolean "hubstats"
  end

  create_table "hubstats_teams_users", force: :cascade do |t|
    t.integer "user_id", limit: 4
    t.integer "team_id", limit: 4
  end

  add_index "hubstats_teams_users", ["team_id"], name: "index_hubstats_teams_users_on_team_id", using: :btree
  add_index "hubstats_teams_users", ["user_id"], name: "index_hubstats_teams_users_on_user_id", using: :btree

  create_table "hubstats_users", force: :cascade do |t|
    t.string   "login",               limit: 255
    t.string   "role",                limit: 255
    t.boolean  "site_admin"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.string   "avatar_url",          limit: 255
    t.string   "gravatar_id",         limit: 255
    t.string   "url",                 limit: 255
    t.string   "html_url",            limit: 255
    t.string   "followers_url",       limit: 255
    t.string   "following_url",       limit: 255
    t.string   "gists_url",           limit: 255
    t.string   "starred_url",         limit: 255
    t.string   "subscriptions_url",   limit: 255
    t.string   "organizations_url",   limit: 255
    t.string   "repos_url",           limit: 255
    t.string   "events_url",          limit: 255
    t.string   "received_events_url", limit: 255
  end

end
