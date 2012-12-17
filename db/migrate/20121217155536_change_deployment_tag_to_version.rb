class ChangeDeploymentTagToVersion < ActiveRecord::Migration
  def change
    rename_column :deployments, :tag, :version
  end
end
