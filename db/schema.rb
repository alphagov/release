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

ActiveRecord::Schema.define(:version => 20131012110946) do

  create_table "applications", :force => true do |t|
    t.string   "name"
    t.string   "repo"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "status_notes"
    t.string   "shortname"
    t.string   "domain"
  end

  add_index "applications", ["name"], :name => "index_applications_on_name", :unique => true
  add_index "applications", ["repo"], :name => "index_applications_on_repo", :unique => true

  create_table "deployments", :force => true do |t|
    t.string   "version"
    t.string   "environment"
    t.integer  "application_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "releases", :force => true do |t|
    t.text     "notes"
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.datetime "deploy_at"
    t.boolean  "released",                   :default => false
    t.datetime "released_at"
    t.integer  "user_id"
    t.text     "product_team_members"
    t.text     "summary"
    t.text     "description_of_changes"
    t.text     "additional_support_notes"
    t.text     "extended_test_period_notes"
  end

  create_table "tasks", :force => true do |t|
    t.integer  "application_id"
    t.string   "version"
    t.text     "description"
    t.text     "application_changes"
    t.boolean  "additional_support_required", :default => false
    t.boolean  "extended_support_required",   :default => false
    t.datetime "created_at",                                     :null => false
    t.datetime "updated_at",                                     :null => false
    t.integer  "release_id"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "uid"
    t.text     "permissions"
    t.boolean  "remotely_signed_out", :default => false
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

end
