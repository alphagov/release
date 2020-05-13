require "test_helper"

class Api::ApplicationsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET show" do
    setup do
      @app = FactoryBot.create(:application)
    end

    should "return a succsessful response" do
      get :show, params: { id: @app.id }
      body = JSON.parse(response.body)

      assert_response :success
      assert_equal "application/json", response.content_type

      assert_equal "Application 1", body["name"]
      assert_equal "application-1", body["shortname"]
      assert_equal "", body["status_notes"]
      assert_equal false, body["archived"]
      assert_equal false, body["on_aws"]
    end
  end
end
