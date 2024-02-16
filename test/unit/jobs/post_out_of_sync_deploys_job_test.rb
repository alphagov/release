require "test_helper"

class PostOutOfSyncDeploysJobTest < ActiveJob::TestCase
  setup do
    Deployment.delete_all
    Application.delete_all
  end

  should "enqueue a SlackPosterJob for each team with out-of-sync apps" do
    response_body = [
      { "app_name" => "account-api", "team" => "#tech-content-interactions-on-platform-govuk" },
      { "app_name" => "asset-manager", "team" => "#govuk-publishing-platform" },
    ].to_json

    stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: response_body)

    app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")
    FactoryBot.create(:deployment, application: app, version: "111", environment: "production EKS")
    FactoryBot.create(:deployment, application: app, version: "222", environment: "staging EKS")
    FactoryBot.create(:deployment, application: app, version: "222", environment: "integration EKS")

    app2 = FactoryBot.create(:application, name: "Asset manager", shortname: "asset-manager")
    FactoryBot.create(:deployment, application: app2, version: "111", environment: "production EKS")
    FactoryBot.create(:deployment, application: app2, version: "111", environment: "staging EKS")
    FactoryBot.create(:deployment, application: app2, version: "222", environment: "integration EKS")

    PostOutOfSyncDeploysJob.perform_now

    expected_message = "Hello :paw_prints:, this is your regular badgering to deploy!\n" \
      "\n" \
      "- <http://release.dev.gov.uk/applications/account-api|Account API> – Production and staging not in sync (<https://github.com/alphagov/account-api/actions/workflows/deploy.yml|Deploy GitHub action>)"
    assert_enqueued_with job: SlackPosterJob, args: [expected_message, "#tech-content-interactions-on-platform-govuk", { "icon_emoji" => ":badger:" }]

    expected_message = "Hello :paw_prints:, this is your regular badgering to deploy!\n" \
      "\n" \
      "- <http://release.dev.gov.uk/applications/asset-manager|Asset manager> – Undeployed changes in integration (<https://github.com/alphagov/asset-manager/actions/workflows/deploy.yml|Deploy GitHub action>)"
    assert_enqueued_with job: SlackPosterJob, args: [expected_message, "#govuk-publishing-platform", { "icon_emoji" => ":badger:" }]
  end

  should "not enqueue a SlackPosterJob if no teams have out-of-sync apps" do
    response_body = [{ "app_name" => "account-api", "team" => "#tech-content-interactions-on-platform-govuk" }].to_json
    stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: response_body)

    app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")
    FactoryBot.create(:deployment, application: app, version: "222", environment: "production EKS")
    FactoryBot.create(:deployment, application: app, version: "222", environment: "staging EKS")
    FactoryBot.create(:deployment, application: app, version: "222", environment: "integration EKS")

    assert_no_enqueued_jobs do
      PostOutOfSyncDeploysJob.perform_now
    end
  end
end
