class AddStatusNotesToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :status_notes, :string
  end
end
