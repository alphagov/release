require "test_helper"

class DeploymentsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "POST create" do
    context "notification API" do
      should "create a deployment record" do
        app = FactoryGirl.create(:application, repo: "org/app")
        post :create, { repo: "org/app", deployment: { version: "release_123", environment: "staging" } }

        deployment = app.reload.deployments.last
        refute_nil deployment
        assert_equal "release_123", deployment.version
        assert_equal "staging", deployment.environment
      end

      context "accepting different 'repo' formats" do
        should "accept a repo specified as a full URL" do
          app = FactoryGirl.create(:application, repo: "org/app")
          assert_difference "app.deployments.count", 1 do
            post :create, { repo: "https://github.com/org/app", deployment: { version: "release_123", environment: "staging" } }
          end
        end

        should "accept a repo specified as a git address" do
          app = FactoryGirl.create(:application, repo: "org/app")
          assert_difference "app.deployments.count", 1 do
            post :create, { repo: "git@github.com:org/app.git", deployment: { version: "release_123", environment: "staging" } }
          end
        end
      end

      context "application doesn't exist" do
        should "create an application" do
          assert_difference "Deployment.count", 1 do
            assert_difference "Application.count", 1 do
              post :create, { repo: "org/new_app", deployment: { version: "release_1", environment: "staging" } }
            end
          end
        end
      end
    end
  end
end
