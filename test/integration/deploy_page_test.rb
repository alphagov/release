require "integration_test_helper"

class DeployPageTest < ActionDispatch::IntegrationTest
  setup do
    login_as_stub_user
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
  end

  test "page handles a single deployment without a previous deployment" do
    application = FactoryBot.create(:application)
    deployment = FactoryBot.create(:deployment, application:, environment: "production")

    visit deployment_path(deployment)

    assert page.has_content?(deployment.id.to_s)
  end

  test "page handles a deployment with a previous deployment" do
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    application = FactoryBot.create(:application)

    commits = [
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
    ]

    stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/compare/release_70...release_80")
      .to_return(headers: { "content-type" => "application/json" }, body: { commits: }.to_json)

    FactoryBot.create(:deployment, application:, environment: "production", version: "release_70")
    deployment = FactoryBot.create(:deployment, application:, environment: "production", version: "release_80")

    visit deployment_path(deployment)

    assert page.has_content?("##{deployment.id}")
    assert page.has_content?("release_70")
    assert page.has_content?("release_80")
    assert page.has_content?("Not recorded")
    assert page.has_content?("Made a change to a thing. WIP! DO NOT DEPLOY!")
  end
end
