RSpec.describe DeploymentStats, type: :model do
  before do
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
  end

  describe "#per_month" do
    it "returns correct data" do
      app = FactoryBot.create(:application)

      # Exclude deploys from current month (it skews the graph)
      FactoryBot.create(:deployment, created_at: Time.zone.now, application: app, environment: "production")

      # Exclude staging deploys
      FactoryBot.create(:deployment, created_at: "2018-01-01", application: app, environment: "staging")

      FactoryBot.create(:deployment, created_at: "2018-01-01", application: app, environment: "production")
      FactoryBot.create_list(:deployment, 3, created_at: "2018-02-01", application: app, environment: "production")

      expected = {
        "2018-01" => 1,
        "2018-02" => 3,
      }

      result = described_class.new.per_month
      expect(result).to eq(expected)
    end
  end

  describe "#per_year" do
    it "returns correct data" do
      app = FactoryBot.create(:application)

      FactoryBot.create(:deployment, created_at: "2018-01-01", application: app, environment: "staging")

      FactoryBot.create(:deployment, created_at: "2016-01-01", application: app, environment: "production")
      FactoryBot.create_list(:deployment, 3, created_at: "2017-01-01", application: app, environment: "production")
      FactoryBot.create(:deployment, created_at: Time.zone.now, application: app, environment: "production")

      expected = {
        2016 => 1,
        2017 => 3,
        Time.zone.now.year => 1,
      }

      result = described_class.new.per_year
      expect(result).to eq(expected)
    end
  end

  describe ".initialize" do
    it "scopes the results" do
      other_app = FactoryBot.create(:application)
      app = FactoryBot.create(:application)

      FactoryBot.create(:deployment, created_at: "2018-01-01", application: other_app, environment: "production")
      FactoryBot.create_list(:deployment, 2, created_at: "2018-02-01", application: app, environment: "production")

      stats = described_class.new(Deployment.where(application_id: app.id)).per_month

      expect(stats).to eq({ "2018-02" => 2 })
    end
  end
end
