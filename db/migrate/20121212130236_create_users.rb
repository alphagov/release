class CreateUsers < ActiveRecord::Migration
  def change
    create_table "users", :force => true do |t|
      t.string   "name"
      t.string   "email"
      t.string   "uid"
      t.text     "permissions"
      t.boolean  "remotely_signed_out", :default => false
      t.timestamps
    end
  end
end
