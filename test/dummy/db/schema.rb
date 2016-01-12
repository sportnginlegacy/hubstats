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

ActiveRecord::Schema.define(:version => 20160112155348) do

  create_table "hubstats_comments", :force => true do |t|
    t.string   "kind"
    t.integer  "user_id"
    t.integer  "pull_request_id"
    t.integer  "repo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "body"
    t.integer  "path"
    t.string   "html_url"
    t.string   "url"
    t.string   "pull_request_url"
  end

  add_index "hubstats_comments", ["pull_request_id"], :name => "index_hubstats_comments_on_pull_request_id"
  add_index "hubstats_comments", ["user_id"], :name => "index_hubstats_comments_on_user_id"

  create_table "hubstats_deploys", :force => true do |t|
    t.string   "git_revision"
    t.integer  "repo_id"
    t.datetime "deployed_at"
    t.integer  "user_id"
  end

  add_index "hubstats_deploys", ["repo_id"], :name => "index_hubstats_deploys_on_repo_id"
  add_index "hubstats_deploys", ["user_id"], :name => "index_hubstats_deploys_on_user_id"

  create_table "hubstats_labels", :force => true do |t|
    t.string "name"
    t.string "color"
    t.string "url"
  end

  create_table "hubstats_labels_pull_requests", :force => true do |t|
    t.integer "pull_request_id"
    t.integer "label_id"
  end

  add_index "hubstats_labels_pull_requests", ["label_id"], :name => "index_hubstats_labels_pull_requests_on_label_id"
  add_index "hubstats_labels_pull_requests", ["pull_request_id"], :name => "index_hubstats_labels_pull_requests_on_pull_request_id"

  create_table "hubstats_pull_requests", :force => true do |t|
    t.integer  "number"
    t.integer  "user_id"
    t.integer  "repo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "closed_at"
    t.integer  "additions"
    t.integer  "deletions"
    t.integer  "comments"
    t.string   "url"
    t.string   "html_url"
    t.string   "issue_url"
    t.string   "state"
    t.string   "title"
    t.string   "merged"
    t.integer  "deploy_id"
    t.integer  "merged_by"
    t.datetime "merged_at"
    t.integer  "team_id"
  end

  add_index "hubstats_pull_requests", ["deploy_id"], :name => "index_hubstats_pull_requests_on_deploy_id"
  add_index "hubstats_pull_requests", ["repo_id"], :name => "index_hubstats_pull_requests_on_repo_id"
  add_index "hubstats_pull_requests", ["team_id"], :name => "index_hubstats_pull_requests_on_team_id"
  add_index "hubstats_pull_requests", ["user_id"], :name => "index_hubstats_pull_requests_on_user_id"

  create_table "hubstats_repos", :force => true do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.string   "full_name"
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "html_url"
  end

  add_index "hubstats_repos", ["owner_id"], :name => "index_hubstats_repos_on_owner_id"

  create_table "hubstats_teams", :force => true do |t|
    t.string  "name"
    t.boolean "hubstats"
  end

  create_table "hubstats_teams_users", :force => true do |t|
    t.integer "user_id"
    t.integer "team_id"
  end

  add_index "hubstats_teams_users", ["team_id"], :name => "index_hubstats_teams_users_on_team_id"
  add_index "hubstats_teams_users", ["user_id"], :name => "index_hubstats_teams_users_on_user_id"

  create_table "hubstats_users", :force => true do |t|
    t.string   "login"
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "avatar_url"
    t.string   "url"
    t.string   "html_url"
  end

end
