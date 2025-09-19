RSpec.describe "Deployments", type: :request do
  before do
    login_as_stub_user
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
  end

  describe "GET /activity" do
    before do
      app = FactoryBot.create(:application)
      FactoryBot.create_list(:deployment, 10, application_id: app.id)
    end

    it "renders the recent deployments page" do
      get "/activity"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:recent)
    end

    it "assigns deployments to the template" do
      get "/activity"

      expect(assigns(:deployments).size).to eq(10)
    end

    it "filters deployments by environment" do
      app = Application.last
      FactoryBot.create_list(:deployment, 2, application_id: app.id, environment: "integration")

      get "/activity", params: { environment_filter: "Integration" }

      expect(assigns(:deployments).size).to eq(2)
      expect(assigns(:deployments).pluck(:environment).uniq).to eq(%w[integration])
    end
  end

  describe "POST /deployments" do
    context "when forgery protection is enabled" do
      around do |example|
        original_setting = ActionController::Base.allow_forgery_protection
        ActionController::Base.allow_forgery_protection = true
        example.call
        ActionController::Base.allow_forgery_protection = original_setting
      end

      it "raises InvalidAuthenticityToken for non-API requests" do
        skip "Reason: WIP"
        expect {
          post deployments_path,
               params: {
                 repo: "org/app",
                 deployment: { version: "1", environment: "env" },
               }, headers: {}
        }.to raise_error(ActionController::InvalidAuthenticityToken)
      end

      it "allows API requests with Authorization header" do
        post deployments_path, params: {
          repo: "org/app",
          deployment: { version: "1", environment: "env" },
        }, headers: { "Authorization" => "Bearer <token>" }

        expect(response).to have_http_status(:ok)
      end
    end

    it "creates a deployment record for an existing application" do
      app = FactoryBot.create(:application, name: "App Name")

      post deployments_path, params: {
        repo: "org/app-name",
        deployment: { version: "v123", environment: "staging" },
      }

      expect(response).to have_http_status(:ok)

      deployment = app.reload.deployments.last
      expect(deployment.version).to eq("v123")
      expect(deployment.environment).to eq("staging")
    end

    context "when application does not exist" do
      it "creates a new application and a deployment" do
        expect {
          post deployments_path, params: {
            repo: "org/new_app",
            deployment: { version: "release_1", environment: "staging" },
          }
        }.to change(Application, :count).by(1).and change(Deployment, :count).by(1)
      end

      it "generates a friendly name" do
        post deployments_path, params: {
          repo: "org/new_app",
          deployment: { version: "release_1", environment: "staging" },
        }

        app = Application.unscoped.last
        expect(app.name).to eq("New App")
      end

      it "inflects API correctly" do
        post deployments_path, params: {
          repo: "org/devops_api",
          deployment: { version: "release_1", environment: "staging" },
        }

        app = Application.unscoped.last
        expect(app.name).to eq("Devops API")
      end

      it "generates a friendly name from repo with dash" do
        post deployments_path, params: {
          repo: "org/new-app",
          deployment: { version: "release_1", environment: "staging" },
        }

        app = Application.unscoped.last
        expect(app.name).to eq("New App")
      end
    end
  end
end
