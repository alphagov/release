RSpec.describe Repo do
  describe ".all" do
    it "returns an array of repositories" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(
        status: 200,
        body: '[{"name": "repo1"}, {"name": "repo2"}]',
      )
      repos = described_class.all

      expect(repos).to be_an(Array)
      expect(repos.length).to eq(2)
    end

    it "handles HTTP errors gracefully" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 404)

      repos = described_class.all

      expect(repos).to be_an(Array)
      expect(repos).to be_empty
    end
  end

  describe ".url" do
    it "gets the GitHub URL for a repository" do
      response_body = [{
        "app_name" => "account-api",
        "links" => { "repo_url" => "https://github.com/alphagov/account-api" },
      }].to_json

      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

      expect(described_class.url(app_name: "Account API")).to eq("https://github.com/alphagov/account-api")
    end
  end

  describe ".shortname" do
    it "gets the shortname for a repository" do
      response_body = [{
        "app_name" => "account-api",
        "shortname" => "account_api",
      }].to_json

      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)

      expect(described_class.shortname(app_name: "account-api")).to eq("account_api")
    end
  end
end
