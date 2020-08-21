require "test_helper"
require "report/deploy_lag_report"

class Report::DeployLagReportTest < ActiveSupport::TestCase
  setup do
    @app = FactoryBot.create(:application)
  end

  test "pair up the Integration <-> Production deployments" do
    deploy = FactoryBot.create(:deployment, environment: "integration", version: "release_123", application: @app)
    prod_deploy = FactoryBot.create(:deployment, environment: "production", version: "release_124", application: @app)

    sequences = Report::DeployLagReport.new.call
    assert_equal(deploy, sequences.first[:deploy])
    assert_equal(prod_deploy, sequences.first[:prod_deploy])
    assert_equal(@app, sequences.first[:app])
    assert_equal(1, sequences.length)
  end

  test "ignore deploys without a production deployment" do
    FactoryBot.create(:deployment, environment: "integration", version: "release_123", application: @app)
    sequences = Report::DeployLagReport.new.call
    assert_equal([], sequences)
  end

  test "ignore deploys that are not a release (e.g. branches)" do
    FactoryBot.create(:deployment, environment: "integration", version: "foo-bar", application: @app)
    FactoryBot.create(:deployment, environment: "production", version: "release_124", application: @app)

    sequences = Report::DeployLagReport.new.call
    assert_equal([], sequences)
  end

  test "ignore the hosting provider (AWS vs. Carrenza)" do
    deploy = FactoryBot.create(:deployment, environment: "integration", version: "release_123", application: @app)
    prod_deploy = FactoryBot.create(:deployment, environment: "production", version: "release_124", application: @app)

    sequences = Report::DeployLagReport.new.call
    assert_equal(deploy, sequences.first[:deploy])
    assert_equal(prod_deploy, sequences.first[:prod_deploy])
  end
end
