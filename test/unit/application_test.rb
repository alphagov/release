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

  context "deployed to EC2" do
    setup do
      @atts = {
        name: "Tron-o-matic",
        repo: "alphagov/tron-o-matic",
      }
    end

    context "when the application is not deployed to EC2" do
      should "return false" do
        application = Application.new(@atts)

        Application.stub :ec2_deployed_apps, ["something-other-than-tron-o-matic"] do
          assert_not application.deployed_to_ec2?
        end
      end
    end

    context "when the application is deployed to EC2" do
      should "return true" do
        application = Application.new(@atts)

        Application.stub :ec2_deployed_apps, ["tron-o-matic"] do
          assert application.deployed_to_ec2?
        end
      end
    end
  end

  context "live environment" do
    setup do
      @atts = {
        name: "Tron-o-matic",
        repo: "alphagov/tron-o-matic",
      }
    end

    context "when the application is not deployed to EC2" do
      should "return production EKS" do
        application = Application.new(@atts)

        Application.stub :ec2_deployed_apps, ["something-other-than-tron-o-matic"] do
          assert_equal "production EKS", application.live_environment
        end
      end
    end

    context "when the application is deployed to EC2" do
      should "return production" do
        application = Application.new(@atts)

        Application.stub :ec2_deployed_apps, ["tron-o-matic"] do
          assert_equal "production", application.live_environment
        end
      end
    end
  end

  describe "#status" do
    before do
      @app = FactoryBot.create(:application, name: SecureRandom.hex, repo: "alphagov/#{SecureRandom.hex}")
      Deployment.delete_all
    end

    context "when the application is deployed to EC2" do
      should "return :all_environments_match when deployments are in sync" do
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "integration")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "staging")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "production")

        @app.stub :deployed_to_ec2?, true do
          assert_equal :all_environments_match, @app.status
        end
      end

      should "return :production_and_staging_not_in_sync when staging and production have different versions" do
        FactoryBot.create(:deployment, application: @app, version: "2", environment: "integration")
        FactoryBot.create(:deployment, application: @app, version: "2", environment: "staging")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "production")

        @app.stub :deployed_to_ec2?, true do
          assert_equal :production_and_staging_not_in_sync, @app.status
        end
      end

      should "return :undeployed_changes_in_integration when there are different version across the environments" do
        FactoryBot.create(:deployment, application: @app, version: "2", environment: "integration")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "staging")
        FactoryBot.create(:deployment, application: @app, version: "1", environment: "production")

        @app.stub :deployed_to_ec2?, true do
          assert_equal :undeployed_changes_in_integration, @app.status
        end
      end
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
end
