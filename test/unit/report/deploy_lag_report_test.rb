require "test_helper"
require "report/deploy_lag_report"

class Report::DeployLagReportTest < ActiveSupport::TestCase
  setup do
    stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: "", headers: {})
    @app = FactoryBot.create(:application)
    @start_date = 1.year.ago.strftime("%Y-%m-%d")
    @end_date = (Time.zone.today + 1).to_s
  end

  test "pair up the Integration <-> Production deployments" do
    deploy = FactoryBot.create(:deployment, environment: "integration", version: "release_123", application: @app)
    prod_deploy = FactoryBot.create(:deployment, environment: "production", version: "release_124", application: @app)
    sequences = Report::DeployLagReport.new.call(@start_date, @end_date)
    assert_equal(deploy, sequences.first[:deploy])
    assert_equal(prod_deploy, sequences.first[:prod_deploy])
    assert_equal(@app, sequences.first[:app])
    assert_equal(1, sequences.length)
  end

  test "ignore deploys without a production deployment" do
    FactoryBot.create(:deployment, environment: "integration", version: "release_123", application: @app)
    sequences = Report::DeployLagReport.new.call(@start_date, @end_date)
    assert_equal([], sequences)
  end

  test "ignore deploys that are not a release (e.g. branches)" do
    FactoryBot.create(:deployment, environment: "integration", version: "foo-bar", application: @app)
    FactoryBot.create(:deployment, environment: "production", version: "release_124", application: @app)

    sequences = Report::DeployLagReport.new.call(@start_date, @end_date)
    assert_equal([], sequences)
  end

  test "ignores deploys that are outside of the selected time range" do
    FactoryBot.create(:deployment, created_at: 2.years.ago, environment: "integration", version: "release_123", application: @app)
    FactoryBot.create(:deployment, created_at: 2.years.ago, environment: "production", version: "release_123", application: @app)

    sequences = Report::DeployLagReport.new.call(@start_date, @end_date)

    assert_equal([], sequences)
  end
end
