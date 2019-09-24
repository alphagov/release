require "test_helper"

class DeploymentsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET recent" do
    setup do
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
  end

  context "GET new" do
    should "preselect the application" do
      FactoryBot.create(
        :application,
        repo: "org/app",
        name: "Application",
      )

      get :new, params: { application_id: "app" }

      assert_select "#deployment_application_id option[selected]", "Application"
    end
  end

  context "POST create" do
    context "manually recording a deployment" do
      should "create a deployment record" do
        app = FactoryBot.create(:application, repo: "org/app")
        post :create, params: { deployment: { application_id: app.id, version: "release_123", environment: "staging", created_at: "18/01/2013 11:57" } }

        deployment = app.reload.deployments.last
        assert_not_nil deployment
        assert_equal "release_123", deployment.version
        assert_equal "staging", deployment.environment
        assert_equal "2013-01-18 11:57:00 +0000", deployment.created_at.to_s
      end

      should "redisplay the form on error" do
        app = FactoryBot.create(:application, repo: "org/app")
        post :create, params: { deployment: { application_id: app.id, version: "", environment: "staging", created_at: "18/01/2013 11:57" } }
        assert_template :new
      end

      should "unarchive an archived application" do
        app = FactoryBot.create(:application, repo: "org/app", archived: true)
        post :create, params: { deployment: { application_id: app.id, version: "release_345", environment: "staging", created_at: "18/01/2013 11:57" } }
        app.reload
        assert_equal false, app.archived
      end
    end

    context "notification API" do
      should "create a deployment record" do
        app = FactoryBot.create(:application, repo: "org/app")
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
        app = FactoryBot.create(:application, repo: "org/app", archived: true)
        post :create, params: { repo: "org/app", deployment: { version: "release_123", environment: "staging" } }
        app.reload
        assert_equal false, app.archived
      end

      context "accepting different 'repo' formats" do
        should "accept a repo specified as a full URL" do
          app = FactoryBot.create(:application, repo: "org/app")
          assert_difference -> { app.deployments.count }, 1 do
            post :create, params: { repo: "https://github.com/org/app", deployment: { version: "release_123", environment: "staging" } }
          end
        end

        should "accept a repo specified as a git address" do
          app = FactoryBot.create(:application, repo: "org/app")
          assert_difference -> { app.deployments.count }, 1 do
            post :create, params: { repo: "git@github.com:org/app.git", deployment: { version: "release_123", environment: "staging" } }
          end
        end
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
end
