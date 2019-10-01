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

  create_table "hubstats_comments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "kind"
    t.integer  "user_id"
    t.integer  "pull_request_id"
    t.integer  "repo_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "body_string"
    t.integer  "path"
    t.string   "html_url"
    t.string   "url"
    t.string   "pull_request_url"
    t.text     "body",             limit: 65535
    t.index ["pull_request_id"], name: "index_hubstats_comments_on_pull_request_id", using: :btree
    t.index ["user_id"], name: "index_hubstats_comments_on_user_id", using: :btree
  end

  create_table "hubstats_deploys", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "git_revision"
    t.integer  "repo_id"
    t.datetime "deployed_at"
    t.integer  "user_id"
    t.index ["repo_id"], name: "index_hubstats_deploys_on_repo_id", using: :btree
    t.index ["user_id"], name: "index_hubstats_deploys_on_user_id", using: :btree
  end

  create_table "hubstats_labels", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "color"
    t.string "url"
  end

  create_table "hubstats_labels_pull_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "pull_request_id"
    t.integer "label_id"
    t.index ["label_id"], name: "index_hubstats_labels_pull_requests_on_label_id", using: :btree
    t.index ["pull_request_id"], name: "index_hubstats_labels_pull_requests_on_pull_request_id", using: :btree
  end

  create_table "hubstats_pull_requests", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
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
    t.index ["deploy_id"], name: "index_hubstats_pull_requests_on_deploy_id", using: :btree
    t.index ["repo_id"], name: "index_hubstats_pull_requests_on_repo_id", using: :btree
    t.index ["team_id"], name: "index_hubstats_pull_requests_on_team_id", using: :btree
    t.index ["user_id"], name: "index_hubstats_pull_requests_on_user_id", using: :btree
  end

  create_table "hubstats_qa_signoffs", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "user_id"
    t.integer  "repo_id"
    t.integer  "pull_request_id"
    t.string   "label_name"
    t.datetime "signed_at"
    t.index ["pull_request_id"], name: "index_hubstats_qa_signoffs_on_pull_request_id", unique: true, using: :btree
    t.index ["repo_id"], name: "index_hubstats_qa_signoffs_on_repo_id", using: :btree
    t.index ["user_id"], name: "index_hubstats_qa_signoffs_on_user_id", using: :btree
  end

  create_table "hubstats_repos", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer  "owner_id"
    t.string   "name"
    t.string   "full_name"
    t.datetime "pushed_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "url"
    t.string   "html_url"
    t.string   "labels_url"
    t.index ["owner_id"], name: "index_hubstats_repos_on_owner_id", using: :btree
  end

  create_table "hubstats_teams", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string  "name"
    t.boolean "hubstats"
  end

  create_table "hubstats_teams_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "team_id"
    t.index ["team_id"], name: "index_hubstats_teams_users_on_team_id", using: :btree
    t.index ["user_id"], name: "index_hubstats_teams_users_on_user_id", using: :btree
  end

  create_table "hubstats_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string   "login"
    t.string   "role"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "avatar_url"
    t.string   "url"
    t.string   "html_url"
  end

end
