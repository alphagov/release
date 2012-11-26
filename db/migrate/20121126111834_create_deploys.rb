class CreateDeploys < ActiveRecord::Migration
  def change
    create_table :deploys do |t|
      t.integer :release
      t.integer :application_id
      t.string :version
      t.text :description
      t.text :application_changes
      t.text :notes
      t.boolean :additional_support_required, default: false
      t.boolean :extended_support_required, default: false

      t.timestamps

      t.references :applications
    end
  end
end
