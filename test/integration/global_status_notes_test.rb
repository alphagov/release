require "integration_test_helper"

class GlobalStatusNotesTest < ActionDispatch::IntegrationTest
  setup do
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    @app1 = FactoryBot.create(:application)
    @app2 = FactoryBot.create(:application)
    login_as_stub_user

    stub_graphql(Github, :application, owner: "alphagov", name: @app1.name.parameterize)
      .to_return(:application)
    stub_graphql(Github, :application, owner: "alphagov", name: @app2.name.parameterize)
      .to_return(:application)
  end

  test "we can add a global status note that is shown on all deploy pages" do
    visit "/"

    click_on @app1.name
    assert page.has_no_selector?(".gem-c-notice")
    assert page.has_no_selector?(".gem-c-error-alert")

    click_on "Settings"

    fill_in "Global status note", with: "Christmas deploy freeze in place. Emergency deploys only until 2nd Jan"
    click_on "Save"
    assert page.has_selector?(".gem-c-success-alert", text: "Settings updated")
    assert_equal "/applications", current_path

    visit "/"
    click_on @app1.name
    assert page.has_selector?(".gem-c-error-alert", text: "Christmas deploy freeze in place. Emergency deploys only until 2nd Jan"), "Global status note is missing from Application 1 deploys page"
    click_on "v185"
    assert page.has_selector?(".gem-c-error-alert", text: "Christmas deploy freeze in place. Emergency deploys only until 2nd Jan"), "Global status note is missing from Application 1 v185 tag deploy page"

    visit "/"

    click_on @app2.name
    assert page.has_selector?(".gem-c-error-alert", text: "Christmas deploy freeze in place. Emergency deploys only until 2nd Jan"), "Global status note is missing from Application 2 deploys page"
    click_on "v184"
    assert page.has_selector?(".gem-c-error-alert", text: "Christmas deploy freeze in place. Emergency deploys only until 2nd Jan"), "Global status note is missing from Application 2 v184 tag deploy page"

    click_on "Settings"
    fill_in "Global status note", with: ""
    click_on "Save"
    assert page.has_selector?(".gem-c-success-alert", text: "Settings updated")
    assert_equal "/applications", current_path

    visit "/"
    click_on @app1.name
    assert page.has_no_selector?(".gem-c-error-alert")
    click_on "v185"
    assert page.has_no_selector?(".gem-c-error-alert")

    visit "/"

    click_on @app2.name
    assert page.has_no_selector?(".gem-c-error-alert")
    click_on "v184"
    assert page.has_no_selector?(".gem-c-error-alert")
  end
end
