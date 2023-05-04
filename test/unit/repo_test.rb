require "test_helper"

class RepoTest < ActiveSupport::TestCase
  describe ".all" do
    should "return an array of repositories" do
      stub_request(:get, "http://docs.publishing.service.gov.uk/repos.json").to_return(
        status: 200,
        body: '[{"name": "repo1"}, {"name": "repo2"}]',
      )
      repos = Repo.all

      assert_instance_of Array, repos
      assert_equal 2, repos.length
    end

    should "handle HTTParty errors gracefully" do
      stub_request(:get, "http://docs.publishing.service.gov.uk/repos.json").to_return(status: 404)

      HTTParty.stub(:get, -> { raise HTTParty::Error }) do
        repos = Repo.all
        assert_instance_of Array, repos
        assert_empty repos
      end
    end
  end
end
