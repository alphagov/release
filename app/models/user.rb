class User < ApplicationRecord
  include GDS::SSO::User

  serialize :permissions, coder: YAML, type: Array
end
