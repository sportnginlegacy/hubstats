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

ActiveRecord::Schema.define(version: 20161222173310) do

  create_table "hubstats_comments", force: :cascade do |t|
    t.string   "kind",             limit: 255
    t.integer  "user_id",          limit: 4
    t.integer  "pull_request_id",  limit: 4
    t.integer  "repo_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "body_string",      limit: 255
    t.integer  "path",             limit: 4
    t.string   "html_url",         limit: 255
    t.string   "url",              limit: 255
    t.string   "pull_request_url", limit: 255
    t.text     "body",             limit: 65535
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
    t.integer  "number",     limit: 4
    t.integer  "user_id",    limit: 4
    t.integer  "repo_id",    limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer  "additions",  limit: 4
    t.integer  "deletions",  limit: 4
    t.integer  "comments",   limit: 4
    t.string   "url",        limit: 255
    t.string   "html_url",   limit: 255
    t.string   "issue_url",  limit: 255
    t.string   "state",      limit: 255
    t.string   "title",      limit: 255
    t.string   "merged",     limit: 255
    t.integer  "deploy_id",  limit: 4
    t.integer  "merged_by",  limit: 4
    t.datetime "merged_at"
    t.integer  "team_id",    limit: 4
  end

  add_index "hubstats_pull_requests", ["deploy_id"], name: "index_hubstats_pull_requests_on_deploy_id", using: :btree
  add_index "hubstats_pull_requests", ["repo_id"], name: "index_hubstats_pull_requests_on_repo_id", using: :btree
  add_index "hubstats_pull_requests", ["team_id"], name: "index_hubstats_pull_requests_on_team_id", using: :btree
  add_index "hubstats_pull_requests", ["user_id"], name: "index_hubstats_pull_requests_on_user_id", using: :btree

  create_table "hubstats_qa_signoffs", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "repo_id",         limit: 4
    t.integer  "pull_request_id", limit: 4
    t.string   "label_name",      limit: 255
    t.datetime "signed_at"
  end

  add_index "hubstats_qa_signoffs", ["pull_request_id"], name: "index_hubstats_qa_signoffs_on_pull_request_id", unique: true, using: :btree
  add_index "hubstats_qa_signoffs", ["repo_id"], name: "index_hubstats_qa_signoffs_on_repo_id", using: :btree
  add_index "hubstats_qa_signoffs", ["user_id"], name: "index_hubstats_qa_signoffs_on_user_id", using: :btree

  create_table "hubstats_repos", force: :cascade do |t|
    t.integer  "owner_id",   limit: 4
    t.string   "name",       limit: 255
    t.string   "full_name",  limit: 255
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url",        limit: 255
    t.string   "html_url",   limit: 255
    t.string   "labels_url", limit: 255
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
    t.string   "login",      limit: 255
    t.string   "role",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_url", limit: 255
    t.string   "url",        limit: 255
    t.string   "html_url",   limit: 255
  end

end
