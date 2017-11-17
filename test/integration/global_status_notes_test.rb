require 'integration_test_helper'

class GlobalStatusNotesTest < ActionDispatch::IntegrationTest
  setup do
    @app1 = FactoryGirl.create(:application)
    @app2 = FactoryGirl.create(:application)
    login_as_stub_user
    stub_deploy_and_release_page_api_requests_for(@app1, 'release_1000')
    stub_deploy_and_release_page_api_requests_for(@app2, 'release_200')
  end

  test "we can add a global status note that is shown on all deploy pages" do
    visit "/"

    click_on @app1.name
    assert page.has_no_selector?('.global-status-note')

    click_on 'Site settings'

    fill_in 'Notes', with: 'Christmas deploy freeze in place. Emergency deploys only until 2nd Jan'
    click_on 'Save settings'
    assert page.has_content?('Site settings updated')
    assert_equal '/applications', current_path


    click_on @app1.name
    assert page.has_selector?('.global-status-note', text: 'Christmas deploy freeze in place. Emergency deploys only until 2nd Jan'), "Global status note is missing from Application 1 deploys page"
    click_on 'release_1000'
    assert page.has_selector?('.global-status-note', text: 'Christmas deploy freeze in place. Emergency deploys only until 2nd Jan'), "Global status note is missing from Application 1 release_1000 tag deploy page"

    visit '/'

    click_on @app2.name
    assert page.has_selector?('.global-status-note', text: 'Christmas deploy freeze in place. Emergency deploys only until 2nd Jan'), "Global status note is missing from Application 2 deploys page"
    click_on 'release_200'
    assert page.has_selector?('.global-status-note', text: 'Christmas deploy freeze in place. Emergency deploys only until 2nd Jan'), "Global status note is missing from Application 2 release_200 tag deploy page"

    click_on 'Site settings'
    fill_in 'Notes', with: ''
    click_on 'Save settings'
    assert page.has_content?('Site settings updated')
    assert_equal '/applications', current_path

    click_on @app1.name
    assert page.has_no_selector?('.global-status-note')
    click_on 'release_1000'
    assert page.has_no_selector?('.global-status-note')

    visit '/'

    click_on @app2.name
    assert page.has_no_selector?('.global-status-note')
    click_on 'release_200'
    assert page.has_no_selector?('.global-status-note')
  end

  def stub_deploy_and_release_page_api_requests_for(application, tag)
    stub_request(:get, "https://api.github.com/repos/#{application.repo}/tags").to_return(body:
      [
        {
          "name": tag,
          "zipball_url": "https://api.github.com/repos/#{application.repo}/zipball/#{tag}",
          "tarball_url": "https://api.github.com/repos/#{application.repo}/tarball/#{tag}",
          "commit": {
            "sha": "1234567890",
            "url": "https://api.github.com/repos/#{application.repo}/commits/f45771538251b6ec0d2cc88982797f28916a7878"
          }
        }
      ]
    )
    stub_request(:get, "https://api.github.com/repos/#{application.repo}/commits").to_return(body:
      [
        {
          "sha": "1234567890",
          "commit": {
            "author": {
              "name": "A. Human",
              "email": "a.human@example.com",
              "date": "2017-11-16T11:55:21Z"
            },
            "message": "Made a change to a thing. WIP! DO NOT DEPLOY!",
            "url": "https://api.github.com/repos/#{application.repo}/git/commits/1234567890",
            "comment_count": 0,
          },
          "url": "https://api.github.com/repos/#{application.repo}/commits/1234567890",
          "html_url": "https://github.com/alphagov/#{application.repo}/1234567890",
          "comments_url": "https://api.github.com/repos/#{application.repo}/commits/1234567890/comments"
        }
      ]
    )
    stub_request(:get, "https://grafana.dev.gov.uk:80/api/dashboards/file/deployment_#{application.shortname}.json").to_return(status: 200, body: "")
  end
end
