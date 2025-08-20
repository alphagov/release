# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.2].define(version: 2025_08_20_144348) do
  create_table "applications", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "status_notes"
    t.string "shortname"
    t.boolean "deploy_freeze", default: false, null: false
    t.string "default_branch", default: "main", null: false
    t.boolean "change_failure_tracking"
    t.string "slack_channel"
    t.index ["name"], name: "index_applications_on_name", unique: true
    t.index ["shortname"], name: "index_applications_on_shortname"
  end

  create_table "change_failures", charset: "utf8mb3", force: :cascade do |t|
    t.integer "deployment_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deployment_id"], name: "fk_rails_3d9f73351e"
  end

  create_table "deployments", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "version"
    t.string "environment"
    t.integer "application_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "deployed_sha"
    t.index ["application_id", "environment", "created_at"], name: "index_deployments_on_application_id_etc"
  end

  create_table "sites", charset: "utf8mb3", force: :cascade do |t|
    t.string "status_notes"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "users", id: :integer, charset: "latin1", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "organisation_slug"
    t.boolean "disabled", default: false
    t.string "organisation_content_id", default: ""
  end

  add_foreign_key "change_failures", "deployments", on_delete: :cascade
end
