RSpec.describe PostOutOfSyncDeploysJob, type: :job do
  describe "#perform" do
    it "enqueues a SlackPosterJob for each team with out-of-sync apps when there are out-of-sync apps" do
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

      allow(SlackPosterJob).to receive(:perform_later)

      expected_message_1 = <<~MESSAGE.strip
        Hello :paw_prints:, this is your regular badgering to deploy!

        - <https://release.test.gov.uk/applications/account-api|Account API> – Production and staging not in sync (<https://github.com/alphagov/account-api/actions/workflows/deploy.yml|Deploy GitHub action>)
      MESSAGE

      expected_message_2 = <<~MESSAGE.strip
        Hello :paw_prints:, this is your regular badgering to deploy!

        - <https://release.test.gov.uk/applications/asset-manager|Asset manager> – Undeployed changes in integration (<https://github.com/alphagov/asset-manager/actions/workflows/deploy.yml|Deploy GitHub action>)
      MESSAGE

      described_class.perform_now

      expect(SlackPosterJob).to have_received(:perform_later).with(
        expected_message_1,
        "#tech-content-interactions-on-platform-govuk",
        { "icon_emoji" => ":badger:" },
      )
      expect(SlackPosterJob).to have_received(:perform_later).with(
        expected_message_2,
        "#govuk-publishing-platform",
        { "icon_emoji" => ":badger:" },
      )
    end

    it "does not enqueue any SlackPosterJobs when there are no out-of-sync apps" do
      response_body = [
        { "app_name" => "account-api", "alerts_team" => "#tech-content-interactions-on-platform-govuk" },
      ].to_json
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

      app = FactoryBot.create(:application)
      %w[production staging integration].each do |env|
        FactoryBot.create(:deployment, application: app, version: "222", environment: env)
      end

      allow(SlackPosterJob).to receive(:perform_later)

      described_class.perform_now

      expect(SlackPosterJob).not_to have_received(:perform_later)
    end
  end
end
