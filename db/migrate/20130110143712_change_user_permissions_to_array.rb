class ChangeUserPermissionsToArray < ActiveRecord::Migration
  class User < ApplicationRecord
    serialize :permissions
  end

  def up
    User.all.each do |user|
      if user.permissions.is_a?(Hash)
        user.permissions = user.permissions["Migratorator"]
        user.save!
      end
    end
  end

  def down
    User.all.each do |user|
      unless user.permissions.nil?
        user.permissions = { "Migratorator" => user.permissions }
        user.save!
      end
    end
  end
end
