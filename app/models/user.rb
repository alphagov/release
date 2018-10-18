class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, Array
end
