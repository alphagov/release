require "test_helper"

class UserTest < ActiveSupport::TestCase
  context "#may_deploy?" do
    should "return true if the user has deploy permissions" do
      user = FactoryGirl.create(:user, permissions: ["signin", "deploy"])

      assert user.may_deploy?
    end

    should "return false if the user does not have deploy permissions" do
      user = FactoryGirl.create(:user, permissions: ["singin"])

      refute user.may_deploy?
    end
  end
end
