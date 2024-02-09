class RemoveRepoColumnFromApplication < ActiveRecord::Migration[7.1]
  def change
    change_table :applications, bulk: true do |t|
      t.remove_index :repo
      t.remove :repo, type: :string
    end
  end
end
