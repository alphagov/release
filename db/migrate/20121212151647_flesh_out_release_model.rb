class FleshOutReleaseModel < ActiveRecord::Migration
  def change
    change_table(:releases) do |t| # rubocop:disable Rails/BulkChangeTable
      t.references :user
      t.text :product_team_members
      t.text :summary
      t.text :description_of_changes
      t.text :additional_support_notes
      t.text :extended_test_period_notes
      t.text :additional_notes
    end
  end
end
