class AddEnableChangeFailureMarkingToApplications < ActiveRecord::Migration[8.1]
  def change
    add_column :applications, :enable_change_failure_marking, :boolean, default: false
  end
end
