class RemoveEksSuffixFromEnvironmentNames < ActiveRecord::Migration[7.1]
  def up
    execute <<-SQL
      UPDATE deployments
      SET environment = REGEXP_REPLACE(environment, ' EKS$', '')
      WHERE environment LIKE '% EKS';
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
