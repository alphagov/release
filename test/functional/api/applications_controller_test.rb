require "test_helper"

class Api::ApplicationsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET show" do
    setup do
      @app = FactoryBot.create(:application, name: "Application 1", repo: "alphagov/application-1")
    end

    should "return a succsessful response" do
      get :show, params: { id: @app.id }
      body = JSON.parse(response.body)

      assert_response :success
      assert_equal "application/json", response.content_type

      assert_equal "Application 1", body["name"]
      assert_equal "application-1", body["shortname"]
      assert_equal "", body["notes"]
      assert_equal false, body["archived"]
      assert_equal false, body["deploy_freeze"]
      assert_equal false, body["hosted_on_aws"]
      assert_equal "https://mygithub.tld/alphagov/application-1", body["repository_url"]
    end
  end
end
