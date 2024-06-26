require "test_helper"

class SitesControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET show" do
    should "render the show template with an empty form if no site settings are persisted" do
      get :show
      assert_template :show

      assert_select "form[action='/site']"
      assert_select ".gem-c-character-count .govuk-textarea[name='site[status_notes]']", ""
    end

    should "render the show template with a form filled with the existing site settings" do
      FactoryBot.create(:site, status_notes: "Deploy freeze in place.")
      get :show
      assert_template :show

      assert_select "form[action='/site']"
      assert_select ".gem-c-character-count .govuk-textarea[name='site[status_notes]']", "Deploy freeze in place."
    end
  end

  context "PATCH update" do
    should "create some site settings if there are none" do
      assert_not Site.settings.persisted?

      patch :update, params: { site: { status_notes: "Deploy freeze in place." } }

      assert Site.settings.persisted?
      assert_equal "Deploy freeze in place.", Site.settings.status_notes
    end

    should "update the exiting site settings if they exist" do
      site_settings = FactoryBot.create(:site, status_notes: "Deploys are frozen for now.")
      patch :update, params: { site: { status_notes: "Deploy freeze in place." } }
      assert_equal "Deploy freeze in place.", site_settings.reload.status_notes
    end

    should "redirect to the root on a successful update" do
      patch :update, params: { site: { status_notes: "Deploy freeze in place." } }
      assert_redirected_to root_path
    end

    should "respond with an unprocessable entity for invalid input" do
      patch :update, params: { site: { status_notes: SecureRandom.alphanumeric(1000) } }
      assert_response :unprocessable_entity
    end
  end
end
