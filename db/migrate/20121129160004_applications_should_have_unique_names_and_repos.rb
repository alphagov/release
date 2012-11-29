class ApplicationsShouldHaveUniqueNamesAndRepos < ActiveRecord::Migration
  def change
    add_index :applications, :name, unique: true
    add_index :applications, :repo, unique: true
  end
end
