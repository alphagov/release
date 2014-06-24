require "test_helper"

class DeploymentsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET recent" do
    setup do
      @application = FactoryGirl.create(:application, name: "Foo")
      @deployments = FactoryGirl.create_list(:deployment, 10, application_id: @application.id)
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
    context "when the user has no deploy permissions" do
      shared_test("actions_requiring_deploy_permission_redirect", 
                  'new', 
                  :get, 
                  :new)
                  
    end
  end

  context "POST create" do
    #TODO hmmm... will break api?
    context "when the user has no deploy permissions" do
      shared_test("actions_requiring_deploy_permission_redirect", 
                  'create', 
                  :post, 
                  :create, 
                  { deployment: { application_id: 123, version: "", environment: "staging", created_at: "18/01/2013 11:57" } })
    end

    context "manually recording a deployment" do
      should "create a deployment record" do
        app = FactoryGirl.create(:application, repo: "org/app")
        post :create, { deployment: { application_id: app.id, version: "release_123", environment: "staging", created_at: "18/01/2013 11:57" } }

        deployment = app.reload.deployments.last
        refute_nil deployment
        assert_equal "release_123", deployment.version
        assert_equal "staging", deployment.environment
        assert_equal "2013-01-18 11:57:00 +0000", deployment.created_at.to_s
      end

      should "redisplay the form on error" do
        app = FactoryGirl.create(:application, repo: "org/app")
        post :create, { deployment: { application_id: app.id, version: "", environment: "staging", created_at: "18/01/2013 11:57" } }
        assert_template :new
      end

      should "unarchive an archived application" do
        app = FactoryGirl.create(:application, repo: "org/app", archived: true)
        post :create, { deployment: { application_id: app.id, version: "release_345", environment: "staging", created_at: "18/01/2013 11:57" } }
        app.reload
        assert_equal false, app.archived
      end
    end

    context "notification API" do
      should "create a deployment record" do
        app = FactoryGirl.create(:application, repo: "org/app")
        post :create, { repo: "org/app", deployment: { version: "release_123", environment: "staging" } }

        deployment = app.reload.deployments.last
        refute_nil deployment
        assert_equal "release_123", deployment.version
        assert_equal "staging", deployment.environment
      end

      should "unarchive an archived application" do
        app = FactoryGirl.create(:application, repo: "org/app", archived: true)
        post :create, { repo: "org/app", deployment: { version: "release_123", environment: "staging" } }
        app.reload
        assert_equal false, app.archived
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

        should "generate a friendly name" do
          post :create, { repo: "org/new_app", deployment: { version: "release_1", environment: "staging" } }
          app = Application.last
          assert_equal "New App", app.name
        end

        should "generate a friendly name from a name with a dash in it" do
          post :create, { repo: "org/new-app", deployment: { version: "release_1", environment: "staging" } }
          app = Application.last
          assert_equal "New App", app.name
        end
      end
    end
  end
end
