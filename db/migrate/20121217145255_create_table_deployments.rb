class CreateTableDeployments < ActiveRecord::Migration
  def change
    create_table(:deployments) do |t|
      t.string :tag
      t.string :environment
      t.references :application
      t.timestamps
    end
  end
end
