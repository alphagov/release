RSpec.describe "Applications", type: :request do
  before do
    login_as_stub_user
    stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
  end

  describe "GET /applications" do
    before do
      response_body = [{
        "app_name" => "app1",
        "links" => { "repo_url" => "https://github.com/user/app1" },
      }].to_json
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)
      app1 = FactoryBot.create(:application, name: "app1", default_branch: "main")
      FactoryBot.create(:application, name: "app2")
      FactoryBot.create(:deployment, application: app1, environment: "staging", version: "release_x")
    end

    it "lists applications" do
      get applications_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_css(".release__application-link", count: 2)
    end

    it "shows the latest deploy to an environment" do
      get applications_path
      expect(response.body).to include(
        "href=\"https://github.com/user/app1/tree/release_x\"",
      )
    end

    it "provides a link to compare with default branch" do
      get applications_path
      expect(response.body).to include(
        "href=\"https://github.com/user/app1/compare/release_x...main\"",
      )
    end
  end

  describe "GET /applications/new" do
    it "renders the form" do
      get new_application_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to have_css("form#new_application")
    end
  end

  describe "POST /applications" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    context "with valid parameters" do
      let(:valid_params) { { application: { name: "My First App" } } }

      it "creates a new application" do
        expect {
          post applications_path, params: valid_params
        }.to change(Application, :count).by(1)
      end

      it "redirects to the application page" do
        post applications_path, params: valid_params
        expect(response).to redirect_to(application_path(Application.last))
      end
    end

    context "with invalid parameters" do
      let(:invalid_params) { { application: { name: "" } } }

      it "renders an error message" do
        post applications_path, params: invalid_params
        expect(response.body).to include("Name is required")
      end

      it "rerenders the form and responds with 422 Unprocessable Entity" do
        post applications_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("form")
      end
    end
  end

  describe "GET /applications/:id" do
    let(:mock_resp) do
      [{
        "spec" => {
          "containers" => [
            { "image" => "govuk.storage.com/test:v111" },
          ],
        },
        "metadata" => {
          "name" => "Application 1",
          "creationTimestamp" => "2025-01-29T14:27:01Z",
          "labels" => { "app.kubernetes.io/instance" => "app1" },
        },
      }]
    end

    let(:app_name) { "Application 1" }

    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
      allow(K8sHelper).to receive(:pods_by_status).and_return(mock_resp)
      stub_graphql(Github, :application, owner: "alphagov", name: app_name.parameterize)
        .to_return(:application)
    end

    it "shows the application name" do
      app = FactoryBot.create(:application)
      get application_path(app)

      expect(response.body).to have_css(".gem-c-heading .gem-c-heading__text", text: app.name)
    end

    it "shows the application shortname" do
      app = FactoryBot.create(:application)
      get application_path(app)

      expect(response.body).to have_css(".gem-c-heading .gem-c-heading__context", text: app.shortname)
    end

    it "shows manual deployed status" do
      app = FactoryBot.create(:application)
      get application_path(app)
      expect(response.body).to have_css(".release__badge--orange", text: "Manually deployed")
    end

    it "shows the deployment freeze badge conditionally" do
      app = FactoryBot.create(:application)
      get application_path(app)
      expect(response.body).not_to have_css(".release__badge", text: "Automatic deployments disabled")

      app.update!(deploy_freeze: true)

      get application_path(app)
      expect(response.body).to have_css(".release__badge", text: "Automatic deployments disabled")
    end

    it "shows the outstanding dependency pull requests" do
      app = FactoryBot.create(:application, name: app_name)
      get application_path(app)

      expect(response.body).to have_link("5 outstanding dependency pull requests")
    end

    it "includes status notes as a warning" do
      app = FactoryBot.create(:application, status_notes: "Do not deploy this without talking to core team first!")
      get application_path(app)
      expect(response.body).to have_css(".gem-c-notice", text: "Do not deploy this without talking to core team first!")
    end

    context "when no running pods found" do
      before do
        allow(K8sHelper).to receive(:pods_by_status).and_return([])
      end

      it "shows no running pods message" do
        app = FactoryBot.create(:application, name: app_name)
        get application_path(app)
        expect(response.body).to have_css("td", text: "No running pods")
      end
    end

    context "when in a non-production environment" do
      before do
        allow(GovukPublishingComponents::AppHelpers::Environment).to receive(:current_acceptance_environment).and_return("integration")
      end

      it "shows Integration and Staging versions of running pods" do
        app = FactoryBot.create(:application, name: app_name)
        get application_path(app)

        expect(response.body).to have_link("Integration", href: "https://argo.eks.Integration.govuk.digital/applications/app1")
        expect(response.body).to have_link("Staging", href: "https://argo.eks.Staging.govuk.digital/applications/app1")
        expect(response.body).to have_css("td", text: /v111.*at 2:27pm on 29 Jan.*Github on v185/, count: 2)
      end
    end

    context "when in production environment" do
      before do
        allow(GovukPublishingComponents::AppHelpers::Environment).to receive(:current_acceptance_environment).and_return("production")
      end

      it "shows the version of running pods for each environment" do
        app = FactoryBot.create(:application, name: app_name)
        get application_path(app)

        expect(response.body).to have_css("td", text: /v111.*at 2:27pm on 29 Jan.*Github on v185/, count: 3)
      end
    end

    context "when format is json" do
      let(:body) do
        [{
          "app_name" => "application-2",
          "links" => { "repo_url" => "https://github.com/alphagov/application-2" },
        }].to_json
      end

      before do
        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: body)
      end

      it "returns a successful JSON response" do
        app = FactoryBot.create(:application, name: "Application 2")
        get application_path(app, format: :json)
        parsed_body = JSON.parse(response.body)

        expect(response).to have_http_status(:success)
        expect(response.content_type).to eq("application/json; charset=utf-8")

        expect(parsed_body["name"]).to eq("Application 2")
        expect(parsed_body["shortname"]).to eq("application-2")
        expect(parsed_body["notes"]).to eq("")
        expect(parsed_body["deploy_freeze"]).to be(false)
        expect(parsed_body["continuously_deployed"]).to be(false)
        expect(parsed_body["repository_url"]).to eq("https://github.com/alphagov/application-2")
      end
    end

    context "when there is a github error" do
      before do
        app = FactoryBot.create(:application)
        graphql_requests.clear
        graphql_responses.clear
        stub_graphql(Github, :application, owner: "alphagov", name: app.name.parameterize)
          .to_return(:errors)

        get application_path(app)
      end

      it "shows the error message" do
        expect(response.body).to have_css(".application-notice.help-notice") do |node|
          expect(node).to have_css("p", text: "Couldn't get data from GitHub:")
          expect(node).to have_css("p", text: "API rate limit exceeded.")
        end
      end
    end

    context "when there is a kubernetes API response error" do
      before do
        error = Kubeclient::HttpError.new(408, "Timeout message", "Timeout response")
        allow(K8sHelper).to receive(:pods_by_status).and_raise(error)
      end

      it "shows the error message" do
        app = FactoryBot.create(:application)
        get application_path(app)

        expect(response.body).to have_css(".application-notice.help-notice") do |node|
          expect(node).to have_css("p", text: "Couldn't get data from kubernetes API:")
          expect(node).to have_css("p", text: "Timeout message")
        end
      end
    end

    context "when there is an AWS STS error" do
      before do
        error = Aws::STS::Errors::ExpiredTokenException.new(
          nil,
          "The security token included in the request is expired",
        )
        allow(K8sHelper).to receive(:pods_by_status).and_raise(error)
      end

      it "shows the error message" do
        app = FactoryBot.create(:application)
        get application_path(app)

        expect(response.body).to have_css(".application-notice.help-notice") do |node|
          expect(node).to have_css("p", text: "Couldn't get data from kubernetes API:")
          expect(node).to have_css("p", text: "The security token included in the request is expired")
        end
      end
    end

    context "when there is a Github Query error" do
      before do
        error = Github::QueryError.new("GitHub error")
        allow(Github).to receive(:application).and_raise(error)
      end

      it "shows the error message" do
        app = FactoryBot.create(:application)
        get application_path(app)

        expect(response.body).to have_css(".application-notice.help-notice") do |node|
          expect(node).to have_css("p", text: "Couldn't get data from GitHub:")
          expect(node).to have_css("p", text: "GitHub error")
        end
      end
    end
  end

  describe "GET /applications/:id/edit" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    it "shows the form with the application name filled in" do
      app = FactoryBot.create(:application)
      get edit_application_path(app)

      expect(response).to have_http_status(:success)
      expect(response.body).to have_css("form.edit_application input[name='application[name]'][value='#{app.name}']")
    end

    it "shows the warning about deployments disabled via GitHub action" do
      app = FactoryBot.create(:application)
      get edit_application_path(app)

      expect(response).to have_http_status(:success)
      expect(response.body).to have_css(".govuk-warning-text__text", text: /Continuous deployment between each environment has to be disabled or enabled * via GitHub action/)
    end
  end

  describe "PUT /applications/:id" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    it "updates the application given valid parameters" do
      app = FactoryBot.create(:application)
      put application_path(app), params: {
        application: { name: "new name", deploy_freeze: true },
      }

      expect(response).to redirect_to(application_path(app))
      follow_redirect!
      app.reload

      expect(app.name).to eq("new name")
      expect(app.deploy_freeze).to be true
    end

    it "re-renders the edit form with error messages given invalid parameters" do
      app = FactoryBot.create(:application)
      put application_path(app), params: {
        application: { name: "" },
      }

      expect(response).to have_http_status(:unprocessable_entity)
      expect(response.body).to include("Name is required")
      expect(response.body).to have_css(".gem-c-error-summary__list-item", text: "Name is required")
      expect(response.body).to have_css("form.edit_application")
    end
  end

  describe "GET /applications/:id/deploy" do
    let(:client) { instance_double(Octokit::Client) }
    let(:app_name) { "app1" }
    let(:release_tag) { "hot_fix_1" }

    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)

      allow(Octokit::Client).to receive(:new).and_return(client)
      allow(client).to receive(:compare)
        .with("alphagov/app1", "v1", release_tag)
        .and_return(OpenStruct.new(commits: [], base_commit: nil))

      stub_request(:get, "https://api.github.com/repos/alphagov/#{app_name}/tags").to_return(body: [])
      stub_request(:get, "https://api.github.com/repos/alphagov/#{app_name}/commits").to_return(body: [])
    end

    it "shows that we are trying to deploy the release" do
      app = FactoryBot.create(:application)
      get deploy_application_path(app), params: { tag: release_tag }

      expect(response).to have_http_status(:ok)
      expect(response.body).to have_css(".gem-c-heading .gem-c-heading__text", text: "Deploy #{release_tag}")
      expect(response.body).to have_css(".gem-c-heading .gem-c-heading__context", text: app.name)
      expect(response.body).to have_css(".govuk-body", text: "Production is not deployed yet!")
    end

    it "includes status notes as a warning" do
      app = FactoryBot.create(:application, status_notes: "Do not deploy this without talking to core team first!")
      get deploy_application_path(app), params: { tag: release_tag }

      expect(response.body).to have_css(".gem-c-notice", text: "Do not deploy this without talking to core team first!")
    end

    it "shows the deployment link" do
      app = FactoryBot.create(:application)
      get deploy_application_path(app), params: { tag: release_tag }

      expect(response.body).to have_css(".gem-c-button[href='#{app.repo_url}/actions/workflows/deploy.yml']")
    end
  end

  describe "POST /applications/:id/destroy" do
    before do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    it "deletes the application" do
      app = FactoryBot.create(:application)
      expect {
        delete application_path(app)
      }.to change(Application, :count).by(-1)
    end

    it "redirects to the index page" do
      app = FactoryBot.create(:application)
      delete application_path(app)
      expect(response).to redirect_to(applications_path)
    end
  end
end
