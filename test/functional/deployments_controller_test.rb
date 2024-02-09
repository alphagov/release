require "test_helper"

class DeploymentsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET recent" do
    setup do
      Deployment.delete_all
      @application = FactoryBot.create(:application, name: "Foo")
      @deployments = FactoryBot.create_list(:deployment, 10, application_id: @application.id)
    end

    should "render the recent template" do
      get :recent

      assert_template "recent"
      assert response.ok?
    end

    should "assign deployments to the template" do
      get :recent

      assert_equal 10, assigns(:deployments).size
    end

    should "assign only filtered environments" do
      FactoryBot.create(:deployment, application_id: @application.id, environment: "integration EKS")
      FactoryBot.create(:deployment, application_id: @application.id, environment: "integration")

      get :recent, params: { environment_filter: "Integration" }

      assert_equal 2, assigns(:deployments).size
    end
  end

  context "POST create using deployment information from Argo" do
    should "create a deployment record" do
      app = FactoryBot.create(:application, name: "App")
      post :create, params: { repo: "org/app", deployment: { version: "release_123", environment: "staging", jenkins_user_email: "user@example.org", jenkins_user_name: "A User", deployed_sha: "02a570885766dc43d5e2432855bbffb342543906" } }

      deployment = app.reload.deployments.last
      assert_not_nil deployment
      assert_equal "release_123", deployment.version
      assert_equal "staging", deployment.environment
      assert_equal "user@example.org", deployment.jenkins_user_email
      assert_equal "A User", deployment.jenkins_user_name
      assert_equal "02a570885766dc43d5e2432855bbffb342543906", deployment.deployed_sha
    end

    should "unarchive an archived application" do
      app = FactoryBot.create(:application, name: "App", archived: true)
      post :create, params: { repo: "org/app", deployment: { version: "release_123", environment: "staging" } }
      app.reload
      assert_equal false, app.archived
    end

    context "application doesn't exist" do
      should "create an application" do
        assert_difference [-> { Deployment.count }, -> { Application.count }], 1 do
          post :create, params: { repo: "org/new_app", deployment: { version: "release_1", environment: "staging" } }
        end
      end

      should "generate a friendly name" do
        post :create, params: { repo: "org/new_app", deployment: { version: "release_1", environment: "staging" } }
        app = Application.unscoped.last
        assert_equal "New App", app.name
      end

      should "inflect API correctly" do
        post :create, params: { repo: "org/devops_api", deployment: { version: "release_1", environment: "staging" } }
        app = Application.unscoped.last
        assert_equal "Devops API", app.name
      end

      should "generate a friendly name from a name with a dash in it" do
        post :create, params: { repo: "org/new-app", deployment: { version: "release_1", environment: "staging" } }
        app = Application.unscoped.last
        assert_equal "New App", app.name
      end
    end
  end
end
