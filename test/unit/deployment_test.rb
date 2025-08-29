require "test_helper"

class DeploymentTest < ActiveSupport::TestCase
  describe "#previous_deployment" do
    should "should return the previous version" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
      app = FactoryBot.create(:application, name: SecureRandom.hex)

      previous = FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "production")
      the_deploy = FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "staging")

      assert_equal previous, the_deploy.previous_deployment
    end
  end

  describe "#commit_match?" do
    def stub_commits(repo_path, prev_sha, current_sha, prev_release, current_release)
      prev_commits = [
        {
          "sha": prev_sha,
          "commit": {
            "author": {
              "name": "A. Human",
              "email": "a.human@example.com",
              "date": "2016-11-16T11:55:21Z",
            },
            "message": "Made a change to a thing. WIP! DO NOT DEPLOY!",
            "url": "https://api.github.com/repos/#{repo_path}/git/commits/#{prev_sha}",
            "comment_count": 0,
          },
          "url": "https://api.github.com/repos/#{repo_path}/commits/#{prev_sha}",
          "html_url": "https://github.com/alphagov/#{repo_path}/#{prev_sha}",
          "comments_url": "https://api.github.com/repos/#{repo_path}/commits/#{prev_sha}/comments",
        },
      ]

      stub_request(:get, "https://api.github.com/repos/#{repo_path}/compare/release_60...#{prev_release}")
        .to_return(headers: { "content-type" => "application/json" }, body: { commits: prev_commits }.to_json)

      commits = [
        {
          "sha": current_sha,
          "commit": {
            "author": {
              "name": "A. Human",
              "email": "a.human@example.com",
              "date": "2017-11-16T11:55:21Z",
            },
            "message": "Made a change to a thing. WIP! DO NOT DEPLOY!",
            "url": "https://api.github.com/repos/#{repo_path}/git/commits/#{current_sha}",
            "comment_count": 0,
          },
          "url": "https://api.github.com/repos/#{repo_path}/commits/#{current_sha}",
          "html_url": "https://github.com/alphagov/#{repo_path}/#{current_sha}",
          "comments_url": "https://api.github.com/repos/#{repo_path}/commits/#{current_sha}/comments",
        },
      ]

      stub_request(:get, "https://api.github.com/repos/#{repo_path}/compare/#{prev_release}...#{current_release}")
        .to_return(headers: { "content-type" => "application/json" }, body: { commits: }.to_json)
    end

    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    should "return true when SHAs are the same" do
      application = FactoryBot.create(:application, name: SecureRandom.hex)
      stub_commits(application.repo_path, "123123123", "c579613e5f0335ecf409fed881fa7919c150c1af", "release_70", "release_80")

      FactoryBot.create(
        :deployment, version: "release_70", application:
      )
      deployment = FactoryBot.create(
        :deployment, version: "release_80", application:
      )
      assert deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end

    should "return false when SHAs are the different" do
      application = FactoryBot.create(:application, name: SecureRandom.hex)
      stub_commits(application.repo_path, "123123123", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "release_70", "release_80")

      FactoryBot.create(
        :deployment, version: "release_70", application:
      )
      deployment = FactoryBot.create(
        :deployment, version: "release_80", application:
      )
      assert_equal false, deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end

    should "return true if sha is a short SHA" do
      application = FactoryBot.create(:application, name: SecureRandom.hex)
      stub_commits(application.repo_path, "123123123", "c57961", "release_70", "release_80")

      FactoryBot.create(
        :deployment, version: "release_70", application:
      )
      deployment = FactoryBot.create(
        :deployment, version: "release_80", application:
      )
      assert deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end

    should "return false if deployed_sha is empty" do
      application = FactoryBot.create(:application, name: SecureRandom.hex)
      stub_commits(application.repo_path, "123123123", "", "release_70", "release_80")

      FactoryBot.create(
        :deployment, version: "release_70", application:
      )

      deployment = FactoryBot.create(:deployment, version: "release_80", application:)
      assert_equal false, deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end

    should "return false if sha too short" do
      application = FactoryBot.create(:application, name: SecureRandom.hex)
      stub_commits(application.repo_path, "123123123", "c57", "release_70", "release_80")

      FactoryBot.create(
        :deployment, version: "release_70", application:
      )
      deployment = FactoryBot.create(
        :deployment, version: "release_80", application:
      )
      assert_equal false, deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")
    end
  end

  describe "#to_live_environment?" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    should "return true if deployment to application's live environment" do
      deployment = FactoryBot.create(:deployment, environment: "production", id: SecureRandom.hex)
      assert deployment.to_live_environment?
    end

    should "return false if deployment not to application's live environment" do
      deployment = FactoryBot.create(:deployment, environment: "test", id: SecureRandom.hex)
      assert_equal false, deployment.to_live_environment?
    end
  end
end
