class AddDefaultBranchToApplication < ActiveRecord::Migration[6.0]
  def change
    add_column :applications, :default_branch, :string, default: "master", null: false
  end
end
