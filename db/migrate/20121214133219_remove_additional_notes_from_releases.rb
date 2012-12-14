class RemoveAdditionalNotesFromReleases < ActiveRecord::Migration
  def up
    remove_column :releases, :additional_notes
  end

  def down
    add_column :releases, :additional_notes, :text
  end
end
