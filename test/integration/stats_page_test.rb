require 'integration_test_helper'

class StatsPageTest < ActionDispatch::IntegrationTest
  setup do
    login_as_stub_user
  end

  test "page with global stats" do
    visit stats_path

    assert page.has_content?("Deployments per month")
  end

  test "page with stats for an application" do
    application = FactoryBot.create(:application)

    visit stats_application_path(application)

    assert page.has_content?("Deployments per month")
  end
end
