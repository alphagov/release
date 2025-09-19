RSpec.describe K8sHelper do
  describe ".k8s_data" do
    it "parses response from Kubernetes API when data exists for an app" do
      filepath = Rails.root.join("spec/fixtures/k8s/running.json")
      mock_resp = JSON.parse(File.read(filepath))
      allow(described_class).to receive(:pods_by_status).and_return(mock_resp)

      expect(described_class.k8s_data("test", "app1").to_json).to eq(
        {
          app_instance: "app1",
          image: "v490",
          created_at: "2025-05-14T08:52:29Z",
        }.to_json,
      )
    end

    it "returns empty/default values when no data exists" do
      allow(described_class).to receive(:pods_by_status).and_return([])

      expect(described_class.k8s_data("test", "app1").to_json).to eq(
        {
          app_instance: "",
          image: "None",
          created_at: "",
        }.to_json,
      )
    end
  end

  describe ".namespace" do
    licensify_apps = %w[licensify-backend licensify-feed licensify-frontend]

    licensify_apps.each do |app_name|
      it "returns 'licensify' for #{app_name}" do
        expect(described_class.namespace(app_name)).to eq("licensify")
      end
    end

    it "returns 'apps' for non-licensify app" do
      expect(described_class.namespace("app1")).to eq("apps")
    end
  end

  describe ".repo_name" do
    licensify_apps = %w[licensify-backend licensify-feed licensify-frontend]

    licensify_apps.each do |app_name|
      it "returns 'licensify' for #{app_name}" do
        expect(described_class.repo_name(app_name)).to eq("licensify")
      end
    end

    it "returns the app name for standard apps" do
      expect(described_class.repo_name("test-app")).to eq("test-app")
    end

    it "returns 'email-alert-service' unchanged" do
      expect(described_class.repo_name("email-alert-service")).to eq("email-alert-service")
    end
  end

  describe ".component" do
    it "returns 'licensify-admin' for licensify-backend" do
      expect(described_class.component("licensify-backend")).to eq("licensify-admin")
    end

    %w[licensify-feed licensify-frontend].each do |app_name|
      it "returns '#{app_name}' for #{app_name}" do
        expect(described_class.component(app_name)).to eq(app_name)
      end
    end

    it "returns 'worker' for email-alert-service" do
      expect(described_class.component("email-alert-service")).to eq("worker")
    end

    it "returns 'app' for non-licensify apps" do
      expect(described_class.component("test-app")).to eq("app")
    end
  end
end
