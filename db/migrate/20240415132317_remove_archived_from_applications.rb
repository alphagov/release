class RemoveArchivedFromApplications < ActiveRecord::Migration[7.1]
  def up
    Application.where(archived: true).delete_all

    remove_column :applications, :archived
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
