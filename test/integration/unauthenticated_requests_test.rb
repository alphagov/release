require "integration_test_helper"

class UnauthenticatedRequestsTest < ActionDispatch::IntegrationTest
  should "not display the signed in user details when not present" do
    visit "/auth/failure"

    assert page.has_no_content?("Signed in as")
  end
end
