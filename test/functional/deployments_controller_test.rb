require "test_helper"

class DeploymentsControllerTest < ActionController::TestCase
  include ActiveJob::TestHelper

  setup do
    login_as_stub_user
  end

  context "GET recent" do
    setup do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
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
      FactoryBot.create(:deployment, application_id: @application.id, environment: "integration")
      FactoryBot.create(:deployment, application_id: @application.id, environment: "integration")
      get :recent, params: { environment_filter: "Integration" }
      assert_equal 2, assigns(:deployments).size
    end
  end

  context "POST create" do
    context "when forgery protection is enabled" do
      setup do
        @controller.allow_forgery_protection = true
      end

      should "enable forgery protection for non-API requests" do
        assert_raises(ActionController::InvalidAuthenticityToken) do
          post :create, params: {
            repo: "org/app",
            deployment: { version: "1", environment: "env" },
          }
        end
      end

      should "skip forgery protection for API requests" do
        request.headers["Authorization"] = "Bearer <token>"
        post :create, params: {
          repo: "org/app",
          deployment: { version: "1", environment: "env" },
        }
        assert_response :ok
      end
    end

    setup do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    should "create a deployment record" do
      app = FactoryBot.create(:application, name: "App Name")
      post :create, params: {
        repo: "org/app-name",
        deployment: { version: "v123", environment: "staging" },
      }

      deployment = app.reload.deployments.last
      assert_not_nil deployment
      assert_equal "v123", deployment.version
      assert_equal "staging", deployment.environment
    end

    context "application doesn't exist" do
      should "create an application" do
        assert_difference [-> { Deployment.count }, -> { Application.count }], 1 do
          post :create, params: {
            repo: "org/new_app",
            deployment: { version: "release_1", environment: "staging" },
          }
        end
      end

      should "generate a friendly name" do
        post :create, params: {
          repo: "org/new_app",
          deployment: { version: "release_1", environment: "staging" },
        }
        app = Application.unscoped.last
        assert_equal "New App", app.name
      end

      should "inflect API correctly" do
        post :create, params: {
          repo: "org/devops_api",
          deployment: { version: "release_1", environment: "staging" },
        }
        app = Application.unscoped.last
        assert_equal "Devops API", app.name
      end

      should "generate a friendly name from a name with a dash in it" do
        post :create, params: {
          repo: "org/new-app",
          deployment: { version: "release_1", environment: "staging" },
        }
        app = Application.unscoped.last
        assert_equal "New App", app.name
      end
    end
  end

  context "PATCH toggle_change_failure" do
    setup do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    context "when application has change failure marking enabled" do
      setup do
        @app = FactoryBot.create(:application, name: SecureRandom.hex, enable_change_failure_marking: true)
      end

      should "toggle change_failure from false to true for production deployments" do
        deployment = FactoryBot.create(:deployment, application: @app, change_failure: false)

        patch :toggle_change_failure, params: { id: deployment.id }

        deployment.reload
        assert deployment.change_failure?
        assert_redirected_to deployment_path(deployment)
      end

      should "toggle change_failure from true to false for production deployments" do
        deployment = FactoryBot.create(:deployment, application: @app, change_failure: true)

        patch :toggle_change_failure, params: { id: deployment.id }

        deployment.reload
        assert_not deployment.change_failure?
        assert_redirected_to deployment_path(deployment)
      end

      should "not allow toggling for non-production deployments" do
        deployment = FactoryBot.create(:deployment, application: @app, environment: "staging")

        patch :toggle_change_failure, params: { id: deployment.id }

        deployment.reload
        assert_not deployment.change_failure?
        assert_redirected_to deployment_path(deployment)
        assert_equal "Change failure marking is not enabled for this application or this is not a production deployment.", flash[:alert]
      end

      context "Slack notifications" do
        should "enqueue a Slack notification when marking as failure and Slack channel is configured" do
          @app.update!(slack_channel_deployment_notification: "#alerts")
          deployment = FactoryBot.create(:deployment, application: @app, change_failure: false)

          assert_enqueued_with(job: SlackPosterJob) do
            patch :toggle_change_failure, params: { id: deployment.id }
          end
        end

        should "not enqueue a Slack notification when unmarking as failure" do
          @app.update!(slack_channel_deployment_notification: "#alerts")
          deployment = FactoryBot.create(:deployment, application: @app, change_failure: true)

          assert_no_enqueued_jobs(only: SlackPosterJob) do
            patch :toggle_change_failure, params: { id: deployment.id }
          end
        end

        should "not enqueue a Slack notification when no Slack channel is configured" do
          deployment = FactoryBot.create(:deployment, application: @app, change_failure: false)

          assert_no_enqueued_jobs(only: SlackPosterJob) do
            patch :toggle_change_failure, params: { id: deployment.id }
          end
        end
      end
    end

    context "when application does not have change failure marking enabled" do
      should "not allow toggling even for production deployments" do
        app = FactoryBot.create(:application, name: SecureRandom.hex, enable_change_failure_marking: false)
        deployment = FactoryBot.create(:deployment, application: app)

        patch :toggle_change_failure, params: { id: deployment.id }

        deployment.reload
        assert_not deployment.change_failure?
        assert_redirected_to deployment_path(deployment)
        assert_equal "Change failure marking is not enabled for this application or this is not a production deployment.", flash[:alert]
      end
    end
  end
end
