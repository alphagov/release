class CreateReleases < ActiveRecord::Migration
  def change
    create_table :releases do |t|
      t.text :notes

      t.timestamps
    end
  end
end
