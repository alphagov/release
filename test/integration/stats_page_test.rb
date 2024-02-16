require "integration_test_helper"

class StatsPageTest < ActionDispatch::IntegrationTest
  setup do
    login_as_stub_user
  end

  test "page with global stats" do
    visit stats_path

    assert page.has_selector?(".gem-c-title__text", text: "Deployments per month")
  end

  test "page with stats for an application" do
    stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: "", headers: {})

    application = FactoryBot.create(:application)

    visit stats_application_path(application)

    assert page.has_selector?(".gem-c-heading", text: "Deployments per month")
  end
end
