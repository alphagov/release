class AddChangeFailureToDeployments < ActiveRecord::Migration[7.2]
  def change
    add_column :deployments, :change_failure, :boolean, default: false, null: false
  end
end
