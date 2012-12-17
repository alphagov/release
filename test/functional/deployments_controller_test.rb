require "test_helper"

class DeploymentsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "POST create" do
    context "notification API" do
      should "create a deployment record" do
        app = FactoryGirl.create(:application, repo: "org/app")
        post :create, { repo: "org/app", deployment: { tag: "release_123", environment: "staging" } }

        deployment = app.reload.deployments.last
        refute_nil deployment
        assert_equal "release_123", deployment.tag
        assert_equal "staging", deployment.environment
      end

      should "accept a repo specified as a full URL" do
        app = FactoryGirl.create(:application, repo: "org/app")
        assert_difference "Deployment.count", 1 do
          post :create, { repo: "https://github.com/org/app", deployment: { tag: "release_123", environment: "staging" } }
        end
      end

      should "create an application if it's new" do
        assert_difference "Deployment.count", 1 do
          assert_difference "Application.count", 1 do
            post :create, { repo: "org/new_app", deployment: { tag: "release_1", environment: "staging" } }
          end
        end
      end
    end
  end
end
