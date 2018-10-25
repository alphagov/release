class AddOnAwsToApplication < ActiveRecord::Migration[5.2]
  def change
    add_column :applications, :on_aws, :boolean, null: false, default: false
  end
end
