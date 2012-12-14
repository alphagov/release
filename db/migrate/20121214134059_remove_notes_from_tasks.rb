class RemoveNotesFromTasks < ActiveRecord::Migration
  def up
    remove_column :tasks, :notes
  end

  def down
    add_column :tasks, :notes, :text
  end
end
