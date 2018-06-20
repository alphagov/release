class AddExtraInfoToDeployments < ActiveRecord::Migration[5.2]
  def change
    add_column :deployments, :jenkins_user_email, :string
    add_column :deployments, :jenkins_user_name, :string
    add_column :deployments, :deployed_sha, :string
  end
end
