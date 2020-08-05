class RemoveGithubDomainColumnFromApplication < ActiveRecord::Migration[5.2]
  def change
    remove_column :applications, :domain, :string
  end
end
