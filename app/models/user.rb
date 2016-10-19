class User < ApplicationRecord
  include GDS::SSO::User
  
  serialize :permissions, Array

  def may_deploy?
    permissions.include? "deploy"
  end
end
