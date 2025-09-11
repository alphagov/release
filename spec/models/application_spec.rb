RSpec.describe Application do
  include ApplicationHelper

  before do
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
  end

  describe "validations" do
    it "is valid with valid attributes" do
      application = described_class.new(name: "Tron-o-matic")
      expect(application).to be_valid
      application.save!
      expect(application).to be_persisted
    end

    it "is invalid with an empty name" do
      application = described_class.new(name: "")

      expect(application).not_to be_valid
    end

    it "is invalid with a duplicate name" do
      FactoryBot.create(:application, name: "Tron-o-matic")
      application = described_class.new(name: "Tron-o-matic")

      expect(application).not_to be_valid
      expect(application.errors[:name]).to include("has already been taken")
    end

    it "defaults to not be in deploy freeze" do
      application = described_class.new

      expect(application).not_to be_deploy_freeze
    end

    it "is invalid with a name that is too long" do
      application = described_class.new(name: "a" * 256)

      expect(application).not_to be_valid
    end

    it "is invalid with status_notes that are too long" do
      long_notes = "This app is n#{'o' * 233}t working!"
      application = described_class.new(name: "Tron-o-matic", status_notes: long_notes)

      expect(application).not_to be_valid
    end
  end

  describe "#cd_enabled?" do
    it "returns false if not continuously deployed" do
      app = described_class.new(name: "Tron-o-matic")
      expect(app).not_to be_cd_enabled

      allow(described_class).to receive(:cd_statuses).and_return(%w[something-else])
      expect(app).not_to be_cd_enabled
    end

    it "returns true if continuously deployed" do
      app = described_class.new(name: "Tron-o-matic")
      allow(described_class).to receive(:cd_statuses).and_return(["tron-o-matic"])

      expect(app).to be_cd_enabled
    end
  end

  describe "#live_environment" do
    it "returns production" do
      app = described_class.new

      expect(app.live_environment).to eq("production")
    end
  end

  describe "#status" do
    let(:app) { FactoryBot.create(:application) }

    it "returns :all_environments_match when all environments match" do
      %w[integration staging production].each do |env|
        FactoryBot.create(:deployment, application: app, version: "1", environment: env)
      end

      expect(app.status).to eq(:all_environments_match)
    end

    it "returns :production_and_staging_not_in_sync when they differ" do
      FactoryBot.create(:deployment, application: app, version: "2", environment: "integration")
      FactoryBot.create(:deployment, application: app, version: "2", environment: "staging")
      FactoryBot.create(:deployment, application: app, version: "1", environment: "production")

      expect(app.status).to eq(:production_and_staging_not_in_sync)
    end

    it "returns :undeployed_changes_in_integration for integration difference" do
      FactoryBot.create(:deployment, application: app, version: "2", environment: "integration")
      FactoryBot.create(:deployment, application: app, version: "1", environment: "staging")
      FactoryBot.create(:deployment, application: app, version: "1", environment: "production")

      expect(app.status).to eq(:undeployed_changes_in_integration)
    end
  end

  describe "#latest_deploys_by_environment" do
    it "orders main environments" do
      app = FactoryBot.create(:application)
      FactoryBot.create(:deployment, application: app, environment: "production")
      FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "integration")

      expect(app.latest_deploys_by_environment.keys).to eq(%w[integration staging production])
    end

    it "ignores non-main environments" do
      app = FactoryBot.create(:application)
      FactoryBot.create(:deployment, application: app, environment: "training")
      FactoryBot.create(:deployment, application: app, environment: "preview")
      FactoryBot.create(:deployment, application: app, environment: "production")
      FactoryBot.create(:deployment, application: app, environment: "staging")
      FactoryBot.create(:deployment, application: app, environment: "integration")

      expect(app.latest_deploys_by_environment.keys).to eq(%w[integration staging production])
    end

    it "handles applications with only one environment" do
      app = FactoryBot.create(:application)
      FactoryBot.create(:deployment, application: app, environment: "production")

      expect(app.latest_deploys_by_environment.keys).to eq(%w[production])
    end
  end

  describe "#repo_url" do
    it "returns the repository url from metadata" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(
        status: 200,
        body: [{ "app_name" => "account-api", "links" => { "repo_url" => "https://github.com/alphagov/account-api" } }].to_json,
      )
      app = FactoryBot.create(:application, name: "Account API")

      expect(app.repo_url).to eq("https://github.com/alphagov/account-api")
    end

    it "constructs the url if not explicitly provided or it's empty" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(
        status: 200,
        body: [{ "app_name" => "account-api" }].to_json,
      )

      app = FactoryBot.create(:application, name: "Account API")
      expect(app.repo_url).to eq("https://github.com/alphagov/account-api")
    end
  end

  describe "#fallback_shortname" do
    it "returns shortname from metadata" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(
        status: 200,
        body: [{ "app_name" => "account-api", "shortname" => "account_api" }].to_json,
      )
      app = FactoryBot.create(:application, name: "Account API")

      expect(app.fallback_shortname).to eq("account_api")
      expect(app.shortname).to eq("account_api")
    end

    it "constructs shortname from name if missing" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(
        status: 200,
        body: [{ "app_name" => "account-api" }].to_json,
      )
      app = FactoryBot.create(:application, name: "Account API")

      expect(app.fallback_shortname).to eq("account-api")
      expect(app.shortname).to eq("account-api")
    end
  end

  describe "#team_name" do
    it "returns alerts_team from metadata" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(
        status: 200,
        body: [{
          "app_name" => "account-api",
          "alerts_team" => "#tech-content-interactions-on-platform-govuk",
        }].to_json,
      )
      app = FactoryBot.create(:application, name: "Account API", shortname: "account-api")

      expect(app.team_name).to eq("#tech-content-interactions-on-platform-govuk")
    end

    it "returns general dev slack channel when it can't find team (because app names don't match)" do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(
        status: 200,
        body: [{
          "app_name" => "content-data-admin",
          "alerts_team" => "#govuk-platform-security-reliability-team",
        }].to_json,
      )
      app = FactoryBot.create(:application, name: "Content Data", shortname: "content-data")

      expect(app.team_name).to eq("#govuk-developers")
    end
  end

  describe ".out_of_sync" do
    it "returns apps that are out of sync across environments" do
      app1 = FactoryBot.create(:application, name: "Account API", shortname: "account-api")
      FactoryBot.create(:deployment, application: app1, version: "111", environment: "production")
      FactoryBot.create(:deployment, application: app1, version: "111", environment: "staging")
      FactoryBot.create(:deployment, application: app1, version: "222", environment: "integration")

      app2 = FactoryBot.create(:application, name: "Asset manager", shortname: "asset-manager")
      FactoryBot.create(:deployment, application: app2, version: "111", environment: "production")
      FactoryBot.create(:deployment, application: app2, version: "222", environment: "staging")
      FactoryBot.create(:deployment, application: app2, version: "222", environment: "integration")

      app3 = FactoryBot.create(:application, name: "Release", shortname: "release")
      %w[production staging integration].each do |env|
        FactoryBot.create(:deployment, application: app3, version: "222", environment: env)
      end

      expect(described_class.out_of_sync).to contain_exactly(app1, app2)
    end
  end

  describe "#current_image_deployed_by_environment" do
    let(:k8s_response) do
      [{
        "spec" => {
          "containers" => [{ "image" => "govuk.storage.com/test:v111" }],
        },
        "metadata" => {
          "name" => "Application 1",
          "creationTimestamp" => "2025-01-29T14:27:01Z",
          "labels" => { "app.kubernetes.io/instance" => "app1" },
        },
      }]
    end

    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
      allow(K8sHelper).to receive(:pods_by_status).and_return(k8s_response)
    end

    it "returns deployed images for integration and staging environment in sync" do
      app = FactoryBot.create(:application)
      %w[integration staging].each do |env|
        FactoryBot.create(:deployment, application: app, version: "v222", environment: env)
      end

      expected = {
        "integration" => {
          "app_instance" => "app1",
          "image" => "v111",
          "created_at" => "2025-01-29T14:27:01Z",
          "previous_version" => nil,
          "github" => "",
        },
        "staging" => {
          "app_instance" => "app1",
          "image" => "v111",
          "created_at" => "2025-01-29T14:27:01Z",
          "previous_version" => nil,
          "github" => "",
        },
      }

      expect(app.current_image_deployed_by_environment).to eq(expected)
    end
  end
end
