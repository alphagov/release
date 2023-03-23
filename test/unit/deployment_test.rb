require "test_helper"

class DeploymentTest < ActiveSupport::TestCase
  describe "#previous_deployment" do
    should "should return the previous version" do
      app = FactoryBot.create(:application, name: SecureRandom.hex, repo: "alphagov/#{SecureRandom.hex}")

      previous = FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "production")
      the_deploy = FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "staging")

      assert_equal previous, the_deploy.previous_deployment
    end
  end

  describe "#commit_match?" do
    should "return true when SHAs are the same" do
      deployment = FactoryBot.create(:deployment, deployed_sha: "c579613e5f0335ecf409fed881fa7919c150c1af")

      assert_equal true, deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end

    should "return false when SHAs are the different" do
      deployment = FactoryBot.create(:deployment, deployed_sha: "0fa90a3bc5b1c91e9355de3507244e11d8a2d68c")

      assert_equal false, deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end

    should "return true if deployed_sha is a short SHA" do
      deployment = FactoryBot.create(:deployment, deployed_sha: "c579613")

      assert_equal true, deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end

    should "return false if deployed_sha is nil" do
      deployment = FactoryBot.create(:deployment, deployed_sha: nil)

      assert_equal false, deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end

    should "return false if deployed_sha too short" do
      deployment = FactoryBot.create(:deployment, deployed_sha: "c5")

      assert_equal false, deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end
  end

  describe "#to_live_environment?" do
    should "return true if deployment to application's live environment" do
      deployment = FactoryBot.create(:deployment, environment: "production EKS")

      assert_equal true, deployment.to_live_environment?
    end

    should "return false if deployment not to application's live environment" do
      deployment = FactoryBot.create(:deployment, environment: "test")

      assert_equal false, deployment.to_live_environment?
    end
  end
end
