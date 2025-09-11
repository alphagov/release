RSpec.describe PostOutOfSyncDeploysJob, type: :job do
  include ActiveJob::TestHelper

  xdescribe "#perform_now" do
    context "when there are out-of-sync apps" do
      it "enqueues a SlackPosterJob for each team with out-of-sync apps" do
        response_body = [
          { "app_name" => "account-api", "alerts_team" => "#tech-content-interactions-on-platform-govuk" },
          { "app_name" => "asset-manager", "alerts_team" => "#govuk-publishing-platform" },
        ].to_json

        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

        app1 = FactoryBot.create(:application, name: "Account API", shortname: "account-api")
        FactoryBot.create(:deployment, application: app1, version: "111", environment: "production")
        FactoryBot.create(:deployment, application: app1, version: "222", environment: "staging")
        FactoryBot.create(:deployment, application: app1, version: "222", environment: "integration")

        app2 = FactoryBot.create(:application, name: "Asset manager", shortname: "asset-manager")
        FactoryBot.create(:deployment, application: app2, version: "111", environment: "production")
        FactoryBot.create(:deployment, application: app2, version: "111", environment: "staging")
        FactoryBot.create(:deployment, application: app2, version: "222", environment: "integration")

        expected_message_1 = <<~MESSAGE.strip
          Hello :paw_prints:, this is your regular badgering to deploy!

          - <http://release.dev.gov.uk/applications/account-api|Account API> – Production and staging not in sync (<https://github.com/alphagov/account-api/actions/workflows/deploy.yml|Deploy GitHub action>)
        MESSAGE

        expected_message_2 = <<~MESSAGE.strip
          Hello :paw_prints:, this is your regular badgering to deploy!

          - <http://release.dev.gov.uk/applications/asset-manager|Asset manager> – Undeployed changes in integration (<https://github.com/alphagov/asset-manager/actions/workflows/deploy.yml|Deploy GitHub action>)
        MESSAGE

        perform_enqueued_jobs do
          described_class.perform_now

          expect(SlackPosterJob).to have_been_enqueued.with(
            expected_message_1,
            "#tech-content-interactions-on-platform-govuk",
            { "icon_emoji" => ":badger:" },
          )

          expect(SlackPosterJob).to have_been_enqueued.with(
            expected_message_2,
            "#govuk-publishing-platform",
            { "icon_emoji" => ":badger:" },
          )
        end
      end
    end

    context "when there are no out-of-sync apps" do
      it "does not enqueue any SlackPosterJobs" do
        response_body = [
          { "app_name" => "account-api", "alerts_team" => "#tech-content-interactions-on-platform-govuk" },
        ].to_json

        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

        app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")
        FactoryBot.create(:deployment, application: app, version: "222", environment: "production")
        FactoryBot.create(:deployment, application: app, version: "222", environment: "staging")
        FactoryBot.create(:deployment, application: app, version: "222", environment: "integration")

        expect {
          described_class.perform_now
        }.not_to have_enqueued_job(SlackPosterJob)
      end
    end
  end
end
