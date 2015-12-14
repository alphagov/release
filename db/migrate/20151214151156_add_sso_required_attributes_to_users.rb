class AddSsoRequiredAttributesToUsers < ActiveRecord::Migration
  def change
    add_column :users, :disabled, :boolean, default: false, nullable: false
    add_column :users, :organisation_content_id, :string, default: '', nullable: false
  end
end
