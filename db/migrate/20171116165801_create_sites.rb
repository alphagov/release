class CreateSites < ActiveRecord::Migration[5.1]
  def change
    create_table :sites do |t|
      t.string :status_notes

      t.timestamps
    end
  end
end
