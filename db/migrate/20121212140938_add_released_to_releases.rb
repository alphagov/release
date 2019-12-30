class AddReleasedToReleases < ActiveRecord::Migration
  def change
    add_column :releases, :released, :boolean, default: false # rubocop:disable Rails/BulkChangeTable
    add_column :releases, :released_at, :datetime
  end
end
