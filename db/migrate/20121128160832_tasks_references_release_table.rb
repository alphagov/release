class TasksReferencesReleaseTable < ActiveRecord::Migration
  def up
    change_table :tasks do |t|
      t.references :release
    end
  end

  def down
    remove_column :tasks, :release_id
  end
end
