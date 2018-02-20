require "test_helper"
require "gds-sso/lint/user_test"

class GDS::SSO::Lint::UserTest
  def user_class
    ::User
  end
end

class UserTest < ActiveSupport::TestCase
  context "#may_deploy?" do
    should "return true if the user has deploy permissions" do
      user = FactoryBot.create(:user, permissions: %w(signin deploy))

      assert user.may_deploy?
    end

    should "return false if the user does not have deploy permissions" do
      user = FactoryBot.create(:user, permissions: ["singin"])

      refute user.may_deploy?
    end
  end
end
