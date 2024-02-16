require "test_helper"

class BreadcrumbHelperTest < ActionView::TestCase
  should "return a hash of title and url" do
    stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: "", headers: {})
    app_name = SecureRandom.hex
    app = FactoryBot.create(:application, name: app_name)

    expected_hash = {
      title: app_name,
      url: "/applications/#{app_name}",
    }

    assert_equal expected_hash, application_node_crumb(application: app)
  end
end
