require "test_helper"

class RepoTest < ActiveSupport::TestCase
  describe ".all" do
    should "return an array of repositories" do
      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(
        status: 200,
        body: '[{"name": "repo1"}, {"name": "repo2"}]',
      )
      repos = Repo.all

      assert_instance_of Array, repos
      assert_equal 2, repos.length
    end

    should "handle HTTParty errors gracefully" do
      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 404)

      HTTParty.stub(:get, -> { raise HTTParty::Error }) do
        repos = Repo.all
        assert_instance_of Array, repos
        assert_empty repos
      end
    end
  end

  describe ".url" do
    should "get the GitHub URL for a repository" do
      response_body = [{ "app_name" => "account-api",
                         "links" => { "repo_url" => "https://github.com/alphagov/account-api" } }].to_json
      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: response_body)

      assert_equal "https://github.com/alphagov/account-api", Repo.url(app_name: "Account API")
    end
  end

  describe ".shortname" do
    should "get the shortname for a repository" do
      response_body = [{ "app_name" => "account-api",
                         "shortname" => "account_api" }].to_json
      stub_request(:get, "http://docs.publishing.service.gov.uk/apps.json").to_return(status: 200, body: response_body)

      assert_equal "account_api", Repo.shortname(app_name: "account-api")
    end
  end
end
