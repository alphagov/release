class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, coder: JSON, type: Array
end
