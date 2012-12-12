class AddReleasedToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :released, :boolean, :default => false
    add_column :releases, :released_at, :datetime
  end
end
