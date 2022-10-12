class ChangeOnAwsColumnName < ActiveRecord::Migration[7.0]
  def change
    remove_column(:applications, :on_aws, type: :boolean)
  end
end
