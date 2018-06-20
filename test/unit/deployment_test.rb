require 'test_helper'

class DeploymentTest < ActiveSupport::TestCase
  describe '#previous_deployment' do
    should 'should return the previous version' do
      app = FactoryBot.create(:application, name: SecureRandom.hex, repo: "alphagov/" + SecureRandom.hex)

      previous = FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "production")
      the_deploy = FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "staging")

      assert_equal previous, the_deploy.previous_deployment
    end
  end
end
