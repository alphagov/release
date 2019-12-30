class RemoveUnusedModels < ActiveRecord::Migration
  def up
    drop_table :tasks
    drop_table :releases
  end

  def down
    create_table "releases", force: :cascade do |t|
      t.text     "notes", limit: 65535
      t.datetime "created_at",                                               null: false
      t.datetime "updated_at",                                               null: false
      t.datetime "deploy_at"
      t.boolean  "released", limit: 1, default: false
      t.datetime "released_at"
      t.integer  "user_id",                    limit: 4
      t.text     "product_team_members",       limit: 65535
      t.text     "summary",                    limit: 65535
      t.text     "description_of_changes",     limit: 65535
      t.text     "additional_support_notes",   limit: 65535
      t.text     "extended_test_period_notes", limit: 65535
    end

    create_table "tasks", force: :cascade do |t|
      t.integer  "application_id",              limit: 4
      t.string   "version",                     limit: 255
      t.text     "description",                 limit: 65535
      t.text     "application_changes",         limit: 65535
      t.boolean  "additional_support_required", limit: 1,     default: false
      t.boolean  "extended_support_required",   limit: 1,     default: false
      t.datetime "created_at",                                                null: false
      t.datetime "updated_at",                                                null: false
      t.integer  "release_id", limit: 4
    end
  end
end
