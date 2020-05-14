class AddDeployFreezeToApplications < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :deploy_freeze, :boolean, default: false, null: false
  end
end
