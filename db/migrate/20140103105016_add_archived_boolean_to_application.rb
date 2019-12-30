class AddArchivedBooleanToApplication < ActiveRecord::Migration
  def up
    add_column :applications, :archived, :boolean, default: false, null: false
  end

  def down
    remove_column :applications, :archived
  end
end
