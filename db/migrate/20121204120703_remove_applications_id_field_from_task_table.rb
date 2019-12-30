class RemoveApplicationsIdFieldFromTaskTable < ActiveRecord::Migration
  def change
    remove_column :tasks, :applications_id # rubocop:disable Rails/ReversibleMigration
  end
end
