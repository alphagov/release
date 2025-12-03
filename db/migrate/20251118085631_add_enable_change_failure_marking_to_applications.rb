class AddEnableChangeFailureMarkingToApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :applications, :enable_change_failure_marking, :boolean, default: false, null: false # rubocop:disable Rails/BulkChangeTable
    add_column :applications, :slack_channel_deployment_notification, :string
  end
end
