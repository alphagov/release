class AddDeployAtToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :deploy_at, :datetime
  end
end
