require "test_helper"

class DeploymentStatsTest < ActiveSupport::TestCase
  describe "#per_month" do
    should "return correct data" do
      Deployment.delete_all

      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: "", headers: {})
      app = FactoryBot.create(:application, name: SecureRandom.hex)

      # Don't include deploys from this month (it skews the graph)
      FactoryBot.create(:deployment, created_at: Time.zone.now, application: app, environment: "production")

      # Don't include staging deploys
      FactoryBot.create(:deployment, created_at: "2018-01-01", application: app, environment: "staging")

      FactoryBot.create(:deployment, created_at: "2018-01-01", application: app, environment: "production")
      FactoryBot.create(:deployment, created_at: "2018-02-01", application: app, environment: "production")
      FactoryBot.create(:deployment, created_at: "2018-02-01", application: app, environment: "production")
      FactoryBot.create(:deployment, created_at: "2018-02-01", application: app, environment: "production")

      expected = {
        "2018-01" => 1,
        "2018-02" => 3,
      }

      assert_equal(expected, DeploymentStats.new.per_month)
    end
  end

  describe "#per_year" do
    should "return correct data" do
      Deployment.delete_all

      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: "", headers: {})
      app = FactoryBot.create(:application, name: SecureRandom.hex)

      # Don't include staging deploys
      FactoryBot.create(:deployment, created_at: "2018-01-01", application: app, environment: "staging")

      FactoryBot.create(:deployment, created_at: "2016-01-01", application: app, environment: "production")
      FactoryBot.create(:deployment, created_at: "2017-01-01", application: app, environment: "production")
      FactoryBot.create(:deployment, created_at: "2017-01-01", application: app, environment: "production")
      FactoryBot.create(:deployment, created_at: "2017-01-01", application: app, environment: "production")

      # Do include deploys from this year
      FactoryBot.create(:deployment, created_at: Time.zone.now, application: app, environment: "production")

      expected = {
        2016 => 1,
        2017 => 3,
        Time.zone.now.year => 1,
      }

      assert_equal(expected, DeploymentStats.new.per_year)
    end
  end

  describe ".initialize" do
    should "scope the results" do
      Deployment.delete_all

      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: "", headers: {})
      other_app = FactoryBot.create(:application, name: SecureRandom.hex)
      app = FactoryBot.create(:application, name: SecureRandom.hex)

      # Don't include other apps' deployments
      FactoryBot.create(:deployment, created_at: "2018-01-01", application: other_app, environment: "production")

      FactoryBot.create(:deployment, created_at: "2018-02-01", application: app, environment: "production")
      FactoryBot.create(:deployment, created_at: "2018-02-01", application: app, environment: "production")

      expected = {
        "2018-02" => 2,
      }

      stats = DeploymentStats.new(Deployment.where(application_id: app.id)).per_month

      assert_equal(expected, stats)
    end
  end
end
