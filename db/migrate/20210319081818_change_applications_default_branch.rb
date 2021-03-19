class ChangeApplicationsDefaultBranch < ActiveRecord::Migration[6.0]
  def change
    change_column_default :applications, :default_branch, from: "master", to: "main"
  end
end
