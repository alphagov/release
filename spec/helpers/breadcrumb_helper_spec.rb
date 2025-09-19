RSpec.describe BreadcrumbHelper, type: :helper do
  describe "#application_node_crumb" do
    it "returns a hash of title and url" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)

      app = FactoryBot.create(:application)

      expected_hash = {
        title: app.name,
        url: "/applications/#{app.name.parameterize}",
      }

      expect(helper.application_node_crumb(application: app)).to eq(expected_hash)
    end
  end
end
