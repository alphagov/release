class MultipleApplicationsCanHaveSameRepo < ActiveRecord::Migration[5.2]
  def change
    remove_index :applications, :repo
    add_index :applications, :repo, unique: false
  end
end
