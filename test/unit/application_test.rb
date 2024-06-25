require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  include ApplicationHelper

  context "creating an application" do
    setup do
      @atts = {
        name: "Tron-o-matic",
      }
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    context "given valid attributes" do
      should "be created successfully" do
        application = Application.new(@atts)
        assert application.valid?

        application.save!
        assert application.persisted?
      end
    end

    should "be invalid with an empty name" do
      application = Application.new(@atts.merge(name: ""))
      assert_not application.valid?
    end

    should "be invalid with a duplicate name" do
      FactoryBot.create(:application, name: "Tron-o-matic")
      application = Application.new(@atts)

      assert_not application.valid?
      assert application.errors[:name].include?("has already been taken")
    end

    should "default to not be in deploy freeze" do
      application = Application.new(@atts)
      assert_not application.deploy_freeze?
    end

    should "be invalid with a name that is too long" do
      application = Application.new(@atts.merge(name: ("a" * 256)))
      assert_not application.valid?
    end

    should "be invalid with status_notes that are too long" do
      application = Application.new(@atts.merge(status_notes: "This app is n#{'o' * 233}t working!"))

      assert_not application.valid?
    end
  end

  context "display datetimes" do
    should "use the word today if the release was today" do
      assert_equal "10:02am today",
                   human_datetime(Time.zone.now.change(hour: 10, min: 2))
    end

    should "use the word yesterday if the release was yesterday" do
      deploy_time = Time.zone.now.change(hour: 10, min: 2) - 1.day
      assert_equal "10:02am yesterday", human_datetime(deploy_time)
    end

    should "use the day of the week for the current week" do
      Timecop.freeze(Time.zone.parse("2014-07-04 12:44")) do  # Friday
        deploy_time = Time.zone.parse("2014-06-30 10:02")
        assert_equal "10:02am on Monday", human_datetime(deploy_time)
      end
    end

    should "display the date for last Sunday" do
      Timecop.freeze(Time.zone.parse("2014-07-04 12:44")) do  # Friday
        deploy_time = Time.zone.parse("2014-06-29 10:02")
        assert_equal "10:02am on 29 Jun", human_datetime(deploy_time)
      end
    end
  end

  context "continuous deployment" do
    setup do
      @atts = {
        name: "Tron-o-matic",
      }
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    context "when the application is not continuously deployed" do
      should "return false" do
        application = Application.new(@atts)

        assert_not application.cd_enabled?

        Application.stub :cd_statuses, ["something-other-than-tron-o-matic"] do
          assert_not application.cd_enabled?
        end
      end
    end

    context "when the application is continuously deployed" do
      should "return true" do
        application = Application.new(@atts)
        Application.stub :cd_statuses, ["tron-o-matic"] do
          assert application.cd_enabled?
        end
      end
    end
  end

  context "live environment" do
    setup do
      @atts = { name: "Tron-o-matic" }
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    should "return production" do
      application = Application.new(@atts)

      assert_equal "production", application.live_environment
    end
  end

  describe "#status" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
      @app = FactoryBot.create(:application, name: SecureRandom.hex)
      Deployment.delete_all
    end

    should "return :all_environments_match when deployments are in sync" do
      FactoryBot.create(:deployment, application: @app, version: "1", environment: "integration")
      FactoryBot.create(:deployment, application: @app, version: "1", environment: "staging")
      FactoryBot.create(:deployment, application: @app, version: "1", environment: "production")

      assert_equal :all_environments_match, @app.status
    end

    should "return :production_and_staging_not_in_sync when staging and production have different versions" do
      FactoryBot.create(:deployment, application: @app, version: "2", environment: "integration")
      FactoryBot.create(:deployment, application: @app, version: "2", environment: "staging")
      FactoryBot.create(:deployment, application: @app, version: "1", environment: "production")

      assert_equal :production_and_staging_not_in_sync, @app.status
    end

    should "return :undeployed_changes_in_integration when there are different version across the environments" do
      FactoryBot.create(:deployment, application: @app, version: "2", environment: "integration")
      FactoryBot.create(:deployment, application: @app, version: "1", environment: "staging")
      FactoryBot.create(:deployment, application: @app, version: "1", environment: "production")

      assert_equal :undeployed_changes_in_integration, @app.status
    end
  end

  describe "#latest_deploys_by_environment" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    should "orders main environments" do
      Deployment.delete_all
      Application.delete_all

      app = FactoryBot.create(:application)

      production = FactoryBot.create(:deployment, application: app, environment: "production")
      staging = FactoryBot.create(:deployment, application: app, environment: "staging")
      integration = FactoryBot.create(:deployment, application: app, environment: "integration")

      expected = {
        "integration" => integration,
        "staging" => staging,
        "production" => production,
      }

      assert_equal(expected.keys, app.latest_deploys_by_environment.keys)
    end

    should "ignores non-main environments" do
      Deployment.delete_all
      Application.delete_all

      app = FactoryBot.create(:application)

      FactoryBot.create(:deployment, application: app, environment: "training")
      FactoryBot.create(:deployment, application: app, environment: "preview")
      production = FactoryBot.create(:deployment, application: app, environment: "production")
      staging = FactoryBot.create(:deployment, application: app, environment: "staging")
      integration = FactoryBot.create(:deployment, application: app, environment: "integration")

      expected = {
        "integration" => integration,
        "staging" => staging,
        "production" => production,
      }

      assert_equal(expected.keys, app.latest_deploys_by_environment.keys)
    end

    should "handle applications with only one environment" do
      Deployment.delete_all
      Application.delete_all

      app = FactoryBot.create(:application)

      production = FactoryBot.create(:deployment, application: app, environment: "production")

      expected = { "production" => production }

      assert_equal(expected.keys, app.latest_deploys_by_environment.keys)
    end
  end

  context "existing application details from the Developer Docs" do
    setup do
      Application.delete_all
      Application.delete_all
    end

    describe "#repo_url" do
      should "return the repository url for the apps" do
        response_body = [{ "app_name" => "account-api", "links" => { "repo_url" => "https://github.com/alphagov/account-api" } }].to_json
        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

        app = FactoryBot.create(:application, name: "Account API")

        assert_equal "https://github.com/alphagov/account-api", app.repo_url
      end

      should "create the repository url using the app name of the url is not provided or empty" do
        response_body = [{ "app_name" => "account-api" }].to_json
        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

        app = FactoryBot.create(:application, name: "Account API")

        assert_equal "https://github.com/alphagov/account-api", app.repo_url
      end
    end

    describe "#fallback_shortname" do
      before do
        Application.delete_all
        Application.delete_all
      end

      should "return the shortname for the app" do
        response_body = [{ "app_name" => "account-api", "shortname" => "account_api" }].to_json
        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

        app = FactoryBot.create(:application, name: "Account API")

        assert_equal "account_api", app.shortname
      end

      should "create the shortname using the app name if the shortname is not provided or empty" do
        response_body = [{ "app_name" => "account-api" }].to_json
        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

        app = FactoryBot.create(:application, name: "Account API")

        assert_equal "account-api", app.shortname
      end
    end
  end

  describe "#team_name" do
    before do
      Application.delete_all
      Deployment.delete_all
    end

    should "return the name of the team that owns the app" do
      response_body = [{ "app_name" => "account-api", "team" => "#tech-content-interactions-on-platform-govuk" }].to_json
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

      app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")

      assert_equal "#tech-content-interactions-on-platform-govuk", app.team_name
    end

    should "return general dev slack channel when it can't find team (because app names don't match)" do
      response_body = [{ "app_name" => "content-data-admin", "team" => "#govuk-platform-security-reliability-team" }].to_json
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

      app = FactoryBot.create(:application, name: "Content Data", shortname: "content-data")

      assert_equal "#govuk-developers", app.team_name
    end
  end

  describe "out_of_sync" do
    before do
      Application.delete_all
      Deployment.delete_all
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    should "return the apps that are out of sync" do
      app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")
      FactoryBot.create(:deployment, application: app, version: "111", environment: "production")
      FactoryBot.create(:deployment, application: app, version: "111", environment: "staging")
      FactoryBot.create(:deployment, application: app, version: "222", environment: "integration")

      app2 = FactoryBot.create(:application, name: "Asset manager", shortname: "asset-manager")
      FactoryBot.create(:deployment, application: app2, version: "111", environment: "production")
      FactoryBot.create(:deployment, application: app2, version: "222", environment: "staging")
      FactoryBot.create(:deployment, application: app2, version: "222", environment: "integration")

      app3 = FactoryBot.create(:application, name: "Release", shortname: "release")
      FactoryBot.create(:deployment, application: app3, version: "222", environment: "production")
      FactoryBot.create(:deployment, application: app3, version: "222", environment: "staging")
      FactoryBot.create(:deployment, application: app3, version: "222", environment: "integration")

      assert_equal [app, app2], Application.out_of_sync
    end
  end
end
