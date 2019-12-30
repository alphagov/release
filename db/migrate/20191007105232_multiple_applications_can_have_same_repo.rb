class MultipleApplicationsCanHaveSameRepo < ActiveRecord::Migration[5.2]
  def change
    remove_index :applications, :repo # rubocop:disable Rails/BulkChangeTable
    add_index :applications, :repo, unique: false
  end
end
