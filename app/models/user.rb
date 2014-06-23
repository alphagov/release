class User < ActiveRecord::Base
  include GDS::SSO::User
  
  serialize :permissions, Array

  attr_accessible :uid, :email, :name, :permissions, as: :oauth

  def may_deploy?
    false
  end
end
