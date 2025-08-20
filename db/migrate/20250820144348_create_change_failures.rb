class CreateChangeFailures < ActiveRecord::Migration[7.2]
  def change
    create_table :change_failures do |t|
      t.integer :deployment_id, null: false
      t.string :description
      t.foreign_key :deployments, column: :deployment_id, on_delete: :cascade

      t.timestamps
    end
  end
end
