class AddShortnameIndexToApplications < ActiveRecord::Migration
  def change
    add_index :applications, :shortname
  end
end
