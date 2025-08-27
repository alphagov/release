class RemoveDeploedShaCol < ActiveRecord::Migration[7.2]
  def change
    remove_column(:deployments, :deployed_sha)
  end
end
