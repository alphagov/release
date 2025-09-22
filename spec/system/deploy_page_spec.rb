RSpec.describe "Deploy page", type: :system do
  before do
    login_as_stub_user
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
  end

  context "when a deployment has no previous deployment" do
    it "displays the deployment page" do
      app = FactoryBot.create(:application)
      deployment = FactoryBot.create(:deployment, application: app)

      visit deployment_path(deployment)
      pp page.html
      expect(page).to have_content(deployment.id.to_s)
    end
  end

  # context "when deployment has a previous deployment with version and SHA" do
  #   it "displays the correct commit information" do
  #     application = FactoryBot.create(:application)

  #     prev_commits = [{
  #       sha: "123123123",
  #       commit: {
  #         author: {
  #           name: "A. Human",
  #           email: "a.human@example.com",
  #           date: "2016-11-16T11:55:21Z",
  #         },
  #         message: "Made a change to a thing. WIP! DO NOT DEPLOY!",
  #       },
  #     }]

  #     stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/compare/release_60...release_70")
  #       .to_return(headers: { "Content-Type" => "application/json" }, body: { commits: prev_commits }.to_json)

  #     commits = [{
  #       sha: "1234567890",
  #       commit: {
  #         author: {
  #           name: "A. Human",
  #           email: "a.human@example.com",
  #           date: "2017-11-16T11:55:21Z",
  #         },
  #         message: "Made a change to a thing. WIP! DO NOT DEPLOY!",
  #       },
  #     }]

  #     stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/compare/release_70...release_80")
  #       .to_return(headers: { "Content-Type" => "application/json" }, body: { commits: }.to_json)

  #     FactoryBot.create(:deployment, application:, environment: "production", version: "release_60")
  #     FactoryBot.create(:deployment, application:, environment: "production", version: "release_70")
  #     deployment = FactoryBot.create(:deployment, application:, environment: "production", version: "release_80")

  #     visit deployment_path(deployment)

  #     expect(page).to have_content("##{deployment.id}")
  #     expect(page).to have_content("Previous version: release_70 (123123123)")
  #     expect(page).to have_content("Deployed version: release_80 (123456789)")
  #     expect(page).to have_content("Not recorded")
  #     expect(page).to have_content("Made a change to a thing. WIP! DO NOT DEPLOY!")
  #   end
  # end

  # context "when deployed version is a SHA but previous version is a release" do
  #   it "shows SHA as deployed version and full info for previous release" do
  #     application = FactoryBot.create(:application)

  #     prev_commits = [{
  #       sha: "123123123",
  #       commit: {
  #         author: { name: "A. Human", email: "a.human@example.com", date: "2016-11-16T11:55:21Z" },
  #         message: "Made a change to a thing. WIP! DO NOT DEPLOY!",
  #       },
  #     }]

  #     stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/compare/release_60...release_70")
  #       .to_return(headers: { "Content-Type" => "application/json" }, body: { commits: prev_commits }.to_json)

  #     commits = [{
  #       sha: "1234567890",
  #       commit: {
  #         author: { name: "A. Human", email: "a.human@example.com", date: "2017-11-16T11:55:21Z" },
  #         message: "Made a change to a thing. WIP! DO NOT DEPLOY!",
  #       },
  #     }]

  #     stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/compare/release_70...1234567890")
  #       .to_return(headers: { "Content-Type" => "application/json" }, body: { commits: }.to_json)

  #     FactoryBot.create(:deployment, application:, environment: "production", version: "release_60")
  #     FactoryBot.create(:deployment, application:, environment: "production", version: "release_70")
  #     deployment = FactoryBot.create(:deployment, application:, environment: "production", version: "1234567890")

  #     visit deployment_path(deployment)

  #     expect(page).to have_content("##{deployment.id}")
  #     expect(page).to have_content("Previous version: release_70 (123123123)")
  #     expect(page).to have_content("Deployed version: 1234567890")
  #     expect(page).to have_content("Not recorded")
  #     expect(page).to have_content("Made a change to a thing. WIP! DO NOT DEPLOY!")
  #   end
  # end

  # context "when previous version is a SHA and deployed version is a release" do
  #   it "displays both versions correctly" do
  #     application = FactoryBot.create(:application)

  #     prev_commits = [{
  #       sha: "123123123",
  #       commit: {
  #         author: { name: "A. Human", email: "a.human@example.com", date: "2016-11-16T11:55:21Z" },
  #         message: "Made a change to a thing. WIP! DO NOT DEPLOY!",
  #       },
  #     }]

  #     stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/compare/release_60...123123123")
  #       .to_return(headers: { "Content-Type" => "application/json" }, body: { commits: prev_commits }.to_json)

  #     commits = [{
  #       sha: "1234567890",
  #       commit: {
  #         author: { name: "A. Human", email: "a.human@example.com", date: "2017-11-16T11:55:21Z" },
  #         message: "Made a change to a thing. WIP! DO NOT DEPLOY!",
  #       },
  #     }]

  #     stub_request(:get, "https://api.github.com/repos/#{application.repo_path}/compare/123123123...release_80")
  #       .to_return(headers: { "Content-Type" => "application/json" }, body: { commits: }.to_json)

  #     FactoryBot.create(:deployment, application:, environment: "production", version: "release_60")
  #     FactoryBot.create(:deployment, application:, environment: "production", version: "123123123")
  #     deployment = FactoryBot.create(:deployment, application:, environment: "production", version: "release_80")

  #     visit deployment_path(deployment)

  #     expect(page).to have_content("##{deployment.id}")
  #     expect(page).to have_content("Previous version: 123123123")
  #     expect(page).to have_content("Deployed version: release_80 (123456789)")
  #     expect(page).to have_content("Not recorded")
  #     expect(page).to have_content("Made a change to a thing. WIP! DO NOT DEPLOY!")
  #   end
  # end
end
