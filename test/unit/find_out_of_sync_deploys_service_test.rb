require "test_helper"

class FindOutOfSyncDeploysServiceTest < ActiveSupport::TestCase
  describe "#call" do
    before do
      Application.delete_all
      Deployment.delete_all
    end

    should "return correct data" do
      response_body = [
        { "app_name" => "account-api", "team" => "#tech-content-interactions-on-platform-govuk" },
        { "app_name" => "asset-manager", "team" => "#govuk-publishing-platform" },
        { "app_name" => "authenticating-proxy", "team" => "#govuk-navigation-tech" },
      ].to_json

      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: response_body)

      app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")
      FactoryBot.create(:deployment, application: app, version: "111", environment: "production EKS")
      FactoryBot.create(:deployment, application: app, version: "111", environment: "staging EKS")
      FactoryBot.create(:deployment, application: app, version: "222", environment: "integration EKS")

      app2 = FactoryBot.create(:application, name: "Asset manager", shortname: "asset-manager")
      FactoryBot.create(:deployment, application: app2, version: "111", environment: "production EKS")
      FactoryBot.create(:deployment, application: app2, version: "222", environment: "staging EKS")
      FactoryBot.create(:deployment, application: app2, version: "222", environment: "integration EKS")

      expected_hash = {
        "#tech-content-interactions-on-platform-govuk" => [
          { name: app.name,
            shortname: app.shortname,
            repo: app.repo,
            status: app.status,
            team: "#tech-content-interactions-on-platform-govuk" },
        ],
        "#govuk-publishing-platform" => [
          { name: app2.name,
            shortname: app2.shortname,
            repo: app2.repo,
            status: app2.status,
            team: "#govuk-publishing-platform" },
        ],
      }

      assert_equal(expected_hash, FindOutOfSyncDeploysService.call)
    end
  end
end
