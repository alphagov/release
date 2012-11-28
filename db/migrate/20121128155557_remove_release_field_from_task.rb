class RemoveReleaseFieldFromTask < ActiveRecord::Migration
  def up
    remove_column :tasks, :release
  end

  def down
    add_column :tasks, :release, :integer
  end
end
