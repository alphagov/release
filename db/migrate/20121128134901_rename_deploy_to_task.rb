class RenameDeployToTask < ActiveRecord::Migration
  def change
    rename_table :deploys, :tasks
  end
end
