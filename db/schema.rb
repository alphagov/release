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

ActiveRecord::Schema.define(version: 20150928150313) do

  create_table "applications", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.string   "repo",         limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.string   "status_notes", limit: 255
    t.string   "shortname",    limit: 255
    t.string   "domain",       limit: 255
    t.boolean  "archived",     limit: 1,   default: false, null: false
  end

  add_index "applications", ["name"], name: "index_applications_on_name", unique: true, using: :btree
  add_index "applications", ["repo"], name: "index_applications_on_repo", unique: true, using: :btree
  add_index "applications", ["shortname"], name: "index_applications_on_shortname", using: :btree

  create_table "deployments", force: :cascade do |t|
    t.string   "version",        limit: 255
    t.string   "environment",    limit: 255
    t.integer  "application_id", limit: 4
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "deployments", ["application_id", "environment", "created_at"], name: "index_deployments_on_application_id_etc", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                limit: 255
    t.string   "email",               limit: 255
    t.string   "uid",                 limit: 255
    t.text     "permissions",         limit: 65535
    t.boolean  "remotely_signed_out", limit: 1,     default: false
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.string   "organisation_slug",   limit: 255
  end

end
