require "integration_test_helper"

class GlobalStatusNotesTest < ActionDispatch::IntegrationTest
  setup do
    stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: "", headers: {})
    @app1 = FactoryBot.create(:application)
    @app2 = FactoryBot.create(:application)
    login_as_stub_user
    stub_deploy_and_release_page_api_requests_for(@app1, "release_1000")
    stub_deploy_and_release_page_api_requests_for(@app2, "release_200")
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
    click_on "release_1000"
    assert page.has_selector?(".gem-c-error-alert", text: "Christmas deploy freeze in place. Emergency deploys only until 2nd Jan"), "Global status note is missing from Application 1 release_1000 tag deploy page"

    visit "/"

    click_on @app2.name
    assert page.has_selector?(".gem-c-error-alert", text: "Christmas deploy freeze in place. Emergency deploys only until 2nd Jan"), "Global status note is missing from Application 2 deploys page"
    click_on "release_200"
    assert page.has_selector?(".gem-c-error-alert", text: "Christmas deploy freeze in place. Emergency deploys only until 2nd Jan"), "Global status note is missing from Application 2 release_200 tag deploy page"

    click_on "Settings"
    fill_in "Global status note", with: ""
    click_on "Save"
    assert page.has_selector?(".gem-c-success-alert", text: "Settings updated")
    assert_equal "/applications", current_path

    visit "/"
    click_on @app1.name
    assert page.has_no_selector?(".gem-c-error-alert")
    click_on "release_1000"
    assert page.has_no_selector?(".gem-c-error-alert")

    visit "/"

    click_on @app2.name
    assert page.has_no_selector?(".gem-c-error-alert")
    click_on "release_200"
    assert page.has_no_selector?(".gem-c-error-alert")
  end

  def stub_deploy_and_release_page_api_requests_for(application, tag)
    stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/tags").to_return(body:
      [
        {
          "name": tag,
          "zipball_url": "https://api.github.com/repos/#{application.repo_path}/zipball/#{tag}",
          "tarball_url": "https://api.github.com/repos/#{application.repo_path}/tarball/#{tag}",
          "commit": {
            "sha": "1234567890",
            "url": "https://api.github.com/repos/#{application.repo_path}/commits/f45771538251b6ec0d2cc88982797f28916a7878",
          },
        },
      ])
    stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/commits").to_return(body:
      [
        {
          "sha": "1234567890",
          "commit": {
            "author": {
              "name": "A. Human",
              "email": "a.human@example.com",
              "date": "2017-11-16T11:55:21Z",
            },
            "message": "Made a change to a thing. WIP! DO NOT DEPLOY!",
            "url": "https://api.github.com/repos/#{application.repo_path}/git/commits/1234567890",
            "comment_count": 0,
          },
          "url": "https://api.github.com/repos/#{application.repo_path}/commits/1234567890",
          "html_url": "https://github.com/alphagov/#{application.repo_path}/1234567890",
          "comments_url": "https://api.github.com/repos/#{application.repo_path}/commits/1234567890/comments",
        },
      ])
    stub_request(:get, "https://grafana.dev.gov.uk:80/api/dashboards/file/#{application.shortname}.json").to_return(status: 200, body: "")

    Octokit::Client.any_instance.stubs(:search_issues)
        .with("repo:#{application.repo_path} is:pr state:open label:dependencies")
        .returns({
          "total_count": 5,
        })
  end
end
