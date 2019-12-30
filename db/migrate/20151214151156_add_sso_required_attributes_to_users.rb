class AddSsoRequiredAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :disabled, :boolean, default: false, nullable: false # rubocop:disable Rails/BulkChangeTable
    add_column :users, :organisation_content_id, :string, default: "", nullable: false
  end
end
