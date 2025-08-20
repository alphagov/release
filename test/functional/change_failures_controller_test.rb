require "test_helper"

class ChangeFailuresControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
    response_body = [{
                       "app_name" => "app1",
                       "links" => { "repo_url" => "https://github.com/user/app1" },
                     }].to_json
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)
  end

  context "application has change failure tracking enabled" do
    context "deployment is to the live environment" do
      setup do
        @application = FactoryBot.create(:application, name: "app1", default_branch: "main", change_failure_tracking: true)
        @deployment = FactoryBot.create(:deployment, application: @application, environment: "production")
      end

      context "GET new" do
        should "render the form" do
          get :new, params: { deployment_id: @deployment.id }
          assert_response :success
          assert_select "form#new_change_failure"
        end
      end

      context "POST create" do
        context "valid request" do
          should "create a change failure" do
            assert_difference "ChangeFailure.count", 1 do
              post :create, params: { deployment_id: @deployment.id, change_failure: { description: "Test description" } }
            end
          end

          should "redirect to the change failure" do
            post :create, params: { deployment_id: @deployment.id, change_failure: { description: "Test description" } }
            assert_redirected_to deployment_change_failure_path(@deployment)
          end
        end
      end

      context "GET show" do
        setup do
          @change_failure = FactoryBot.create(:change_failure, deployment: @deployment)
        end

        should "show the change failure" do
          get :show, params: { deployment_id: @deployment.id }
          assert_response :success
          assert_select "p", text: /Description: #{@change_failure.description}/
        end
      end

      context "GET edit" do
        setup do
          @change_failure = FactoryBot.create(:change_failure, deployment: @deployment)
        end

        should "render the form" do
          get :edit, params: { deployment_id: @deployment.id }
          assert_response :success
          assert_select "form.edit_change_failure"
        end
      end

      context "PUT update" do
        setup do
          @change_failure = FactoryBot.create(:change_failure, deployment: @deployment)
        end

        context "valid request" do
          should "update the change failure" do
            put :update, params: { deployment_id: @deployment.id, change_failure: { description: "Updated description" } }
            @change_failure.reload
            assert_equal "Updated description", @change_failure.description
          end

          should "redirect to the change failure" do
            put :update, params: { deployment_id: @deployment.id, change_failure: { description: "Updated description" } }
            assert_redirected_to deployment_change_failure_path(@deployment)
          end
        end
      end

      context "DELETE destroy" do
        setup do
          @change_failure = FactoryBot.create(:change_failure, deployment: @deployment)
        end

        should "delete the change failure" do
          assert_difference "ChangeFailure.count", -1 do
            delete :destroy, params: { deployment_id: @deployment.id }
          end
        end

        should "redirect to the deployments show page" do
          delete :destroy, params: { deployment_id: @deployment.id }
          assert_redirected_to deployment_path(@deployment)
        end
      end
    end
    context "deployment is to a non-live environment" do
      setup do
        @application = FactoryBot.create(:application, name: "app1", default_branch: "main", change_failure_tracking: true)
        @deployment = FactoryBot.create(:deployment, application: @application, environment: "integration")
      end

      context "GET new" do
        should "return a not found response" do
          get :new, params: { deployment_id: @deployment.id }
          assert_response :not_found
        end
      end

      context "POST create" do
        context "valid request" do
          should "return a not found response" do
            post :create, params: { deployment_id: @deployment.id, change_failure: { description: "Test description" } }
            assert_response :not_found
          end
        end
      end
    end
  end

  context "application has change failure tracking disabled" do
    setup do
      @application = FactoryBot.create(:application, name: "app1", default_branch: "main", change_failure_tracking: false)
      @deployment = FactoryBot.create(:deployment, application: @application)
    end

    context "GET new" do
      should "return a not found response" do
        get :new, params: { deployment_id: @deployment.id }
        assert_response :not_found
      end
    end

    context "POST create" do
      context "valid request" do
        should "return a not found response" do
          post :create, params: { deployment_id: @deployment.id, change_failure: { description: "Test description" } }
          assert_response :not_found
        end
      end
    end
  end
end
