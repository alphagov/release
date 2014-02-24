class AddIndexToDeployments < ActiveRecord::Migration
  def change
    add_index :deployments, [:application_id, :environment, :created_at], :name => "index_deployments_on_application_id_etc"
  end
end
