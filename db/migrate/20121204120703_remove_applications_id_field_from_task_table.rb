class RemoveApplicationsIdFieldFromTaskTable < ActiveRecord::Migration
  def change
    remove_column :tasks, :applications_id
  end
end
