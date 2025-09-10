RSpec.describe Deployment do
  describe "#previous_deployment" do
    it "returns the previous version" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
      app = FactoryBot.create(:application)

      previous = FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "production")
      the_deploy = FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "staging")

      expect(the_deploy.previous_deployment).to eq(previous)
    end
  end

  describe "#commit_match?" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    def stub_commits(repo_path, prev_sha, current_sha, prev_release, current_release)
      prev_commits = [{
        sha: prev_sha,
        commit: {
          author: {
            name: "A. Human",
            email: "a.human@example.com",
            date: "2016-11-16T11:55:21Z",
          },
          message: "Made a change to a thing. WIP! DO NOT DEPLOY!",
          url: "https://api.github.com/repos/#{repo_path}/git/commits/#{prev_sha}",
          comment_count: 0,
        },
        url: "https://api.github.com/repos/#{repo_path}/commits/#{prev_sha}",
        html_url: "https://github.com/alphagov/#{repo_path}/#{prev_sha}",
        comments_url: "https://api.github.com/repos/#{repo_path}/commits/#{prev_sha}/comments",
      }]

      stub_request(:get, "https://api.github.com/repos/#{repo_path}/compare/release_60...#{prev_release}")
        .to_return(headers: { "content-type" => "application/json" }, body: { commits: prev_commits }.to_json)

      commits = [{
        sha: current_sha,
        commit: {
          author: {
            name: "A. Human",
            email: "a.human@example.com",
            date: "2017-11-16T11:55:21Z",
          },
          message: "Made a change to a thing. WIP! DO NOT DEPLOY!",
          url: "https://api.github.com/repos/#{repo_path}/git/commits/#{current_sha}",
          comment_count: 0,
        },
        url: "https://api.github.com/repos/#{repo_path}/commits/#{current_sha}",
        html_url: "https://github.com/alphagov/#{repo_path}/#{current_sha}",
        comments_url: "https://api.github.com/repos/#{repo_path}/commits/#{current_sha}/comments",
      }]

      stub_request(:get, "https://api.github.com/repos/#{repo_path}/compare/#{prev_release}...#{current_release}")
        .to_return(headers: { "content-type" => "application/json" }, body: { commits: }.to_json)
    end

    it "returns true when SHAs are the same" do
      app = FactoryBot.create(:application)
      stub_commits(app.repo_path, "123123123", "c579613e5f0335ecf409fed881fa7919c150c1af", "release_70", "release_80")

      FactoryBot.create(:deployment, version: "release_70", application: app)
      deployment = FactoryBot.create(:deployment, version: "release_80", application: app)

      expect(deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")).to be true
    end

    it "returns false when SHAs are different" do
      app = FactoryBot.create(:application)
      stub_commits(app.repo_path, "123123123", "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx", "release_70", "release_80")

      FactoryBot.create(:deployment, version: "release_70", application: app)
      deployment = FactoryBot.create(:deployment, version: "release_80", application: app)

      expect(deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")).to be false
    end

    it "returns true if sha is a short SHA" do
      app = FactoryBot.create(:application)
      stub_commits(app.repo_path, "123123123", "c57961", "release_70", "release_80")

      FactoryBot.create(:deployment, version: "release_70", application: app)
      deployment = FactoryBot.create(:deployment, version: "release_80", application: app)

      expect(deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")).to be true
    end

    it "returns false if deployed_sha is empty" do
      app = FactoryBot.create(:application)
      stub_commits(app.repo_path, "123123123", "", "release_70", "release_80")

      FactoryBot.create(:deployment, version: "release_70", application: app)
      deployment = FactoryBot.create(:deployment, version: "release_80", application: app)

      expect(deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")).to be false
    end

    it "returns false if sha is too short" do
      app = FactoryBot.create(:application)
      stub_commits(app.repo_path, "123123123", "c57", "release_70", "release_80")

      FactoryBot.create(:deployment, version: "release_70", application: app)
      deployment = FactoryBot.create(:deployment, version: "release_80", application: app)

      expect(deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")).to be false
    end

    it "returns false if there are no commits returned by GitHub API" do
      deployment = FactoryBot.build(:deployment)
      allow(deployment).to receive(:commits).and_return([])

      expect(deployment.commit_match?("c579613e5f0335ecf409fed881fa7919c150c1af")).to be false
    end
  end

  describe "#to_live_environment?" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    it "returns true if deployment is to the application's live environment" do
      deployment = FactoryBot.create(:deployment, environment: "production")

      expect(deployment.to_live_environment?).to be true
    end

    it "returns false if deployment is not to the application's live environment" do
      deployment = FactoryBot.create(:deployment, environment: "test")

      expect(deployment.to_live_environment?).to be false
    end
  end
end
