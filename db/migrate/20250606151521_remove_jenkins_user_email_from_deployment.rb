class RemoveJenkinsUserEmailFromDeployment < ActiveRecord::Migration[7.2]
  def up
    change_table :deployments, bulk: true do |t|
      t.remove :jenkins_user_email
      t.remove :jenkins_user_name
    end
  end

  def down
    change_table :deployments, bulk: true do |t|
      t.string :jenkins_user_email
      t.string :jenkins_user_name
    end
  end
end
