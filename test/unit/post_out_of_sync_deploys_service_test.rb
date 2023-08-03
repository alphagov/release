require "test_helper"

class PostOutOfSyncDeploysServiceTest < ActiveSupport::TestCase
  describe "#call" do
    should "call FindOutOfSyncDeploysService to get a list of out-of-sync deploys" do
      teams_out_of_sync_deploys = {
        "#govuk-publishing-platform" =>
          [{ name: "Asset manager",
             shortname: "asset-manager",
             repo: "alphagov/asset-manager",
             status: :undeployed_changes_in_integration,
             team: "#govuk-publishing-platform" }],
      }

      find_service_mock = Minitest::Mock.new
      find_service_mock.expect(:call, teams_out_of_sync_deploys)

      slack_poster_mock = Minitest::Mock.new
      expected_args = [
        "Hello :paw_prints:, this is your regular badgering to deploy!\n" \
        "\n" \
        "- <http://release.dev.gov.uk/applications/asset-manager|Asset manager> – Undeployed changes in integration (<https://github.com/alphagov/asset-manager/actions/workflows/deploy.yml|Deploy GitHub action>)",
        "#govuk-publishing-platform",
        { "icon_emoji" => ":badger:" },
      ]
      slack_poster_mock.expect(:call, nil, expected_args)

      FindOutOfSyncDeploysService.stub(:call, find_service_mock) do
        SlackPosterWorker.stub(:perform_async, slack_poster_mock) do
          PostOutOfSyncDeploysService.call
          assert_mock find_service_mock
        end
      end
    end

    should "call SlackPosterWorker to post messages with correct payload for each team with out-of-sync deploys" do
      teams_out_of_sync_deploys = {
        "#govuk-publishing-platform" =>
          [{ name: "Asset manager",
             shortname: "asset-manager",
             repo: "alphagov/asset-manager",
             status: :undeployed_changes_in_integration,
             team: "#govuk-publishing-platform" }],
        "#govuk-navigation-tech" =>
          [{ name: "Account API",
             shortname: "account-api",
             repo: "alphagov/account-api",
             status: :production_and_staging_not_in_sync,
             team: "#govuk-navigation-tech" },
           { name: "Authenticating proxy",
             shortname: "authenticating-proxy",
             repo: "alphagov/authenticating-proxy",
             status: :undeployed_changes_in_integration,
             team: "#govuk-navigation-tech" }],
      }
      FindOutOfSyncDeploysService.any_instance.stubs(:call).returns(teams_out_of_sync_deploys)

      slack_poster_mock = Minitest::Mock.new
      expected_message_one_args = [
        "Hello :paw_prints:, this is your regular badgering to deploy!\n" \
        "\n" \
        "- <http://release.dev.gov.uk/applications/asset-manager|Asset manager> – Undeployed changes in integration (<https://github.com/alphagov/asset-manager/actions/workflows/deploy.yml|Deploy GitHub action>)",
        "#govuk-publishing-platform",
        { "icon_emoji" => ":badger:" },
      ]
      expected_message_two_args = [
        "Hello :paw_prints:, this is your regular badgering to deploy!\n" \
          "\n" \
          "- <http://release.dev.gov.uk/applications/account-api|Account API> – Production and staging not in sync (<https://github.com/alphagov/account-api/actions/workflows/deploy.yml|Deploy GitHub action>)\n" \
          "- <http://release.dev.gov.uk/applications/authenticating-proxy|Authenticating proxy> – Undeployed changes in integration (<https://github.com/alphagov/authenticating-proxy/actions/workflows/deploy.yml|Deploy GitHub action>)",
        "#govuk-navigation-tech",
        { "icon_emoji" => ":badger:" },
      ]

      slack_poster_mock.expect(:call, nil, expected_message_one_args)
      slack_poster_mock.expect(:call, nil, expected_message_two_args)

      SlackPosterWorker.stub(:perform_async, slack_poster_mock) do
        PostOutOfSyncDeploysService.call
        assert_mock slack_poster_mock
      end
    end

    should "not call the SlackPosterWorker when no teams have out-of-sync deploys" do
      FindOutOfSyncDeploysService.any_instance.stubs(:call).returns({})

      PostOutOfSyncDeploysService.call
      SlackPosterWorker.any_instance.expects(:perform_async).never
    end
  end
end
