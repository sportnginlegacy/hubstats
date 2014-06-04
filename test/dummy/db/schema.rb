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

  create_table "hubification_comments", :force => true do |t|
    t.string   "html_url"
    t.string   "url"
    t.string   "pull_request_url"
    t.string   "diff_hunk"
    t.string   "path"
    t.string   "position"
    t.string   "original_position"
    t.string   "line"
    t.string   "commit_id"
    t.string   "original_commit_id"
    t.string   "body"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "hubification_pull_requests", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hubification_repos", :force => true do |t|
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "hubification_users", :force => true do |t|
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
