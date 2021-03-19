# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_03_19_081818) do

  create_table "applications", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "repo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status_notes"
    t.string "shortname"
    t.boolean "archived", default: false, null: false
    t.boolean "on_aws", default: false, null: false
    t.boolean "deploy_freeze", default: false, null: false
    t.string "default_branch", default: "main", null: false
    t.index ["name"], name: "index_applications_on_name", unique: true
    t.index ["repo"], name: "index_applications_on_repo"
    t.index ["shortname"], name: "index_applications_on_shortname"
  end

  create_table "deployments", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "version"
    t.string "environment"
    t.integer "application_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "jenkins_user_email"
    t.string "jenkins_user_name"
    t.string "deployed_sha"
    t.index ["application_id", "environment", "created_at"], name: "index_deployments_on_application_id_etc"
  end

  create_table "sites", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "status_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", id: :integer, options: "ENGINE=InnoDB DEFAULT CHARSET=latin1", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "uid"
    t.text "permissions"
    t.boolean "remotely_signed_out", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "organisation_slug"
    t.boolean "disabled", default: false
    t.string "organisation_content_id", default: ""
  end

end
