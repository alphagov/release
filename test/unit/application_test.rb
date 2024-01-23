require "test_helper"

class ApplicationTest < ActiveSupport::TestCase
  include ApplicationHelper

  context "creating an application" do
    setup do
      @atts = {
        name: "Tron-o-matic",
        repo: "alphagov/tron-o-matic",
      }
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

    should "be invalid with an invalid repo" do
      application = Application.new(@atts)

      application.repo = "noslashes"
      assert_not application.valid?
      assert application.errors[:repo].include?("is invalid")

      application.repo = "too/many/slashes"
      assert_not application.valid?
      assert application.errors[:repo].include?("is invalid")

      application.repo = "/slashatfront"
      assert_not application.valid?
      assert application.errors[:repo].include?("is invalid")

      application.repo = "slashatback/"
      assert_not application.valid?
      assert application.errors[:repo].include?("is invalid")
    end

    should "use the second half of the repo name as shortname if shortname not provided or empty" do
      application = Application.create!(@atts)
      assert_equal "tron-o-matic", application.shortname
    end

    should "use the provided shortname if not empty" do
      application = Application.create!(@atts.merge(shortname: "giraffe"))
      assert_equal "giraffe", application.shortname
    end

    should "know its location on the internet" do
      application = Application.new(@atts)

      assert_equal "https://github.com/alphagov/tron-o-matic", application.repo_url
    end

    should "default to not being archived" do
      application = Application.new(@atts)

      assert_equal false, application.archived
    end

    should "default to not be in deploy freeze" do
      application = Application.new(@atts)

      assert_equal false, application.deploy_freeze?
    end

    should "be invalid with a name that is too long" do
      application = Application.new(@atts.merge(name: ("a" * 256)))

      assert_not application.valid?
    end

    should "be invalid with a repo that is too long" do
      application = Application.new(@atts.merge(repo: "alphagov/my-r#{'e' * 243}po"))

      assert_not application.valid?
    end

    should "be invalid with a shortname that is too long" do
      application = Application.new(@atts.merge(shortname: ("a" * 256)))

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

    should "show a year if the date is old" do
      assert_equal "2pm on 3 Jul 2010",
                   human_datetime(Time.zone.now.change(year: 2010, month: 7, day: 3, hour: 14))
    end

    should "show nothing if the date is missing" do
      assert_equal "", human_datetime(nil)
    end
  end

  context "continuous deployment" do
    setup do
      @atts = {
        name: "Tron-o-matic",
        repo: "alphagov/tron-o-matic",
      }
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

  describe "#status" do
    before do
      @app = FactoryBot.create(:application, name: SecureRandom.hex, repo: "alphagov/#{SecureRandom.hex}")
      Deployment.delete_all
    end

    context "when the application is deployed to EKS" do
      should "return :all_environments_match when deployments are in sync" do
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "integration EKS")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "staging EKS")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "production EKS")

        @app.stub :deployed_to_ec2?, false do
          assert_equal :all_environments_match, @app.status
        end
      end

      should "return :production_and_staging_not_in_sync when staging and production have different versions" do
        FactoryBot.create(:deployment, application: @app, version: "2", environment: "integration EKS")
        FactoryBot.create(:deployment, application: @app, version: "2", environment: "staging EKS")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "production EKS")

        @app.stub :deployed_to_ec2?, false do
          assert_equal :production_and_staging_not_in_sync, @app.status
        end
      end

      should "return :undeployed_changes_in_integration when there are different version across the environments" do
        FactoryBot.create(:deployment, application: @app, version: "2", environment: "integration EKS")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "staging EKS")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "production EKS")

        @app.stub :deployed_to_ec2?, false do
          assert_equal :undeployed_changes_in_integration, @app.status
        end
      end
    end
  end

  describe "#latest_deploys_by_environment" do
    should "orders main environments" do
      Deployment.delete_all
      Application.delete_all

      app = FactoryBot.create(:application)

      production = FactoryBot.create(:deployment, application: app, environment: "production EKS")
      staging = FactoryBot.create(:deployment, application: app, environment: "staging EKS")
      integration = FactoryBot.create(:deployment, application: app, environment: "integration EKS")

      expected = {
        "integration EKS" => integration,
        "staging EKS" => staging,
        "production EKS" => production,
      }

      assert_equal(expected.keys, app.latest_deploys_by_environment.keys)
    end

    should "ignores non-main environments" do
      Deployment.delete_all
      Application.delete_all

      app = FactoryBot.create(:application)

      FactoryBot.create(:deployment, application: app, environment: "training")
      FactoryBot.create(:deployment, application: app, environment: "preview")
      production = FactoryBot.create(:deployment, application: app, environment: "production EKS")
      staging = FactoryBot.create(:deployment, application: app, environment: "staging EKS")
      integration = FactoryBot.create(:deployment, application: app, environment: "integration EKS")

      expected = {
        "integration EKS" => integration,
        "staging EKS" => staging,
        "production EKS" => production,
      }

      assert_equal(expected.keys, app.latest_deploys_by_environment.keys)
    end

    should "handle applications with only one environment" do
      Deployment.delete_all
      Application.delete_all

      app = FactoryBot.create(:application)

      production = FactoryBot.create(:deployment, application: app, environment: "production EKS")

      expected = { "production EKS" => production }

      assert_equal(expected.keys, app.latest_deploys_by_environment.keys)
    end
  end

  describe "#team_name" do
    before do
      Application.delete_all
      Deployment.delete_all
    end

    should "return the name of the team that owns the app" do
      response_body = [{ "app_name" => "account-api", "team" => "#tech-content-interactions-on-platform-govuk" }].to_json
      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: response_body)

      app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")

      assert_equal "#tech-content-interactions-on-platform-govuk", app.team_name
    end

    should "return general dev slack channel when it can't find team (because app names don't match)" do
      response_body = [{ "app_name" => "content-data-admin", "team" => "#govuk-platform-security-reliability-team" }].to_json
      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: response_body)

      app = FactoryBot.create(:application, name: "Content Data", shortname: "content-data")

      assert_equal "#govuk-developers", app.team_name
    end
  end

  describe "out_of_sync" do
    before do
      Application.delete_all
      Deployment.delete_all
    end

    should "return the apps that are out of sync" do
      app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")
      FactoryBot.create(:deployment, application: app, version: "111", environment: "production EKS")
      FactoryBot.create(:deployment, application: app, version: "111", environment: "staging EKS")
      FactoryBot.create(:deployment, application: app, version: "222", environment: "integration EKS")

      app2 = FactoryBot.create(:application, name: "Asset manager", shortname: "asset-manager")
      FactoryBot.create(:deployment, application: app2, version: "111", environment: "production EKS")
      FactoryBot.create(:deployment, application: app2, version: "222", environment: "staging EKS")
      FactoryBot.create(:deployment, application: app2, version: "222", environment: "integration EKS")

      app3 = FactoryBot.create(:application, name: "Release", shortname: "release")
      FactoryBot.create(:deployment, application: app3, version: "222", environment: "production EKS")
      FactoryBot.create(:deployment, application: app3, version: "222", environment: "staging EKS")
      FactoryBot.create(:deployment, application: app3, version: "222", environment: "integration EKS")

      assert_equal [app, app2], Application.out_of_sync
    end

    should "not include apps which have been archived" do
      app = FactoryBot.create(:application, name: "Manuals frontend", archived: true)

      FactoryBot.create(:deployment, application: app, version: "111", environment: "production EKS")
      FactoryBot.create(:deployment, application: app, version: "111", environment: "staging EKS")
      FactoryBot.create(:deployment, application: app, version: "222", environment: "integration EKS")

      assert_equal [], Application.out_of_sync
    end
  end
end
