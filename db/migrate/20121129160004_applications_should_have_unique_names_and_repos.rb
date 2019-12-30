class ApplicationsShouldHaveUniqueNamesAndRepos < ActiveRecord::Migration
  def change
    add_index :applications, :name, unique: true # rubocop:disable Rails/BulkChangeTable
    add_index :applications, :repo, unique: true
  end
end
