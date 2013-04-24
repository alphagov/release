class AddShortnameToApplication < ActiveRecord::Migration
  def change
    add_column :applications, :shortname, :string
  end
end
