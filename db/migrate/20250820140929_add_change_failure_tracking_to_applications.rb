class AddChangeFailureTrackingToApplications < ActiveRecord::Migration[7.2]
  def change
    add_column :applications, :change_failure_tracking, :boolean
    add_column :applications, :slack_channel, :string
  end
end
