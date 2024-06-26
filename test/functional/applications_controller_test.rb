require "test_helper"

class ApplicationsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET index" do
    setup do
      response_body = [{
        "app_name" => "app1",
        "links" => { "repo_url" => "https://github.com/user/app1" },
      }].to_json
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body: response_body)
      @app1 = FactoryBot.create(:application, name: "app1", default_branch: "main")
      @app2 = FactoryBot.create(:application, name: "app2")
      @deploy1 = FactoryBot.create(
        :deployment,
        application: @app1,
        environment: "staging",
        version: "release_x",
      )
    end

    should "list applications" do
      get :index
      assert_select ".release__application-link", count: 2
    end

    should "show the latest deploy to an environment" do
      get :index
      assert_select ".gem-c-table .govuk-table__body .govuk-link[href='https://github.com/user/app1/tree/release_x']", "release_x"
    end

    should "provide a link to compare with default branch" do
      get :index
      assert_select ".gem-c-table .govuk-table__body .govuk-link[href=?]", "https://github.com/user/app1/compare/release_x...main"
    end
  end

  context "GET new" do
    should "render the form" do
      get :new
      assert_select "form#new_application"
    end
  end

  context "POST create" do
    setup do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
    end

    context "valid request" do
      should "create an application" do
        assert_difference "Application.count", 1 do
          post :create,
               params: { application: { name: "My First App" } }
        end
      end

      should "redirect to the application" do
        post :create,
             params: { application: { name: "My First App" } }
        assert_redirected_to application_path(Application.last)
      end
    end

    context "invalid request" do
      should "render an error message" do
        post :create, params: { application: { name: "" } }
        assert_select ".gem-c-error-summary__list-item", text: "Name is required"
      end

      should "rerender the form and respond with an unprocessable entity status" do
        post :create, params: { application: { name: "" } }
        assert_template :new
        assert_response :unprocessable_entity
      end
    end
  end

  context "GET show" do
    setup do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)

      @app = FactoryBot.create(:application)
      stub_graphql(Github, :application, owner: "alphagov", name: @app.name.parameterize)
        .to_return(:application)
    end

    should "show the application name" do
      get :show, params: { id: @app.id }
      assert_select ".gem-c-title .gem-c-title__text", text: @app.name
    end

    should "show the application shortname" do
      get :show, params: { id: @app.id }
      assert_select ".gem-c-title .gem-c-title__context", text: @app.shortname
    end

    should "show manual deployed status" do
      get :show, params: { id: @app.id }
      assert_select ".release__badge--orange", "Manually deployed"
    end

    should "show the deployment freeze badge" do
      get :show, params: { id: @app.id }
      assert_select ".release__badge", { text: "Automatic deployments disabled", count: 0 }

      @app.update!(deploy_freeze: true)

      get :show, params: { id: @app.id }
      assert_select ".release__badge", "Automatic deployments disabled"
    end

    should "show the outstanding dependency pull requests" do
      get :show, params: { id: @app.id }
      assert_select "a", "5 outstanding dependency pull requests"
    end

    should "should include status notes as a warning" do
      @app.update!(status_notes: "Do not deploy this without talking to core team first!")
      get :show, params: { id: @app.id }
      assert_select ".gem-c-notice", "Do not deploy this without talking to core team first!"
    end

    context "with manual deployment" do
      setup do
        version = "release_42"
        @deployed_sha = "1dac538d10b181e9b7b46766bc3a72d001a1f703"
        @manual_deploy = SecureRandom.hex(40)
        FactoryBot.create(:deployment, application: @app, environment: "production", version:, deployed_sha: @deployed_sha)
        FactoryBot.create(:deployment, application: @app, environment: "staging", version:, deployed_sha: @deployed_sha)
        FactoryBot.create(:deployment, application: @app, environment: "integration", version: @manual_deploy)
      end

      should "show 'not on default branch' status" do
        get :show, params: { id: @app.id }
        assert_select ".release__badge--orange", { text: "Not on default branch", count: 1 }
      end
    end

    context "GET show with a production deployment" do
      setup do
        version = "release_42"
        @first_commit = "ee37124a286a0b8501776d9bbe55dcb18ccab645"
        @second_commit = "1dac538d10b181e9b7b46766bc3a72d001a1f703"
        @base_commit = "974d1aedf82c068b42dace07984025fd70dfb240"
        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
        FactoryBot.create(:deployment, application: @app, version:, deployed_sha: @first_commit)
      end

      should "show the application" do
        get :show, params: { id: @app.id }
        assert_select ".gem-c-title .gem-c-title__text", text: @app.name
      end

      should "set the commit history in reverse order" do
        get :show, params: { id: @app.id }
        expected = [@second_commit, @first_commit]
        actual = assigns[:commits].pluck(:sha)
        assert_equal(expected, actual)
      end

      should "include the base commit" do
        get :show, params: { id: @app.id }
        assert_equal @first_commit, assigns[:commits].last[:sha]
      end
    end

    context "when format is json" do
      setup do
        body = [{
          "app_name" => "application-2",
          "links" => { "repo_url" => "https://github.com/alphagov/application-2" },
        }].to_json
        stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200, body:)
        @app = FactoryBot.create(:application, name: "Application 2")
      end

      should "return a successful response" do
        get :show, params: { id: @app.id }, format: :json
        body = JSON.parse(response.body)

        assert_response :success
        assert_equal "application/json", response.media_type

        assert_equal "Application 2", body["name"]
        assert_equal "application-2", body["shortname"]
        assert_equal "", body["notes"]
        assert_equal false, body["deploy_freeze"]
        assert_equal false, body["continuously_deployed"]
        assert_equal "https://github.com/alphagov/application-2", body["repository_url"]
      end
    end

    context "when there is a github error" do
      setup do
        graphql_requests.clear
        graphql_responses.clear
        stub_graphql(Github, :application, owner: "alphagov", name: @app.name.parameterize)
          .to_return(:errors)

        get :show, params: { id: @app.id }
      end

      should "show the error message" do
        assert_select ".application-notice.help-notice" do
          assert_select "p", "Couldn't get data from GitHub:"
          assert_select "p", "API rate limit exceeded."
        end
      end
    end
  end

  context "GET edit" do
    setup do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
      @app = FactoryBot.create(:application, name: "monkeys")
    end

    should "show the form" do
      get :edit, params: { id: @app.id }
      assert_select "form.edit_application input[name='application[name]'][value='#{@app.name}']"
    end

    should "show warning that an deployed app has have deployments disabled via GitHub action" do
      get :edit, params: { id: @app.id }
      assert_select ".govuk-warning-text__text", /Continuous deployment between each environment has to be disabled or enabled * via GitHub action/
    end
  end

  context "PUT update" do
    setup do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
      @app = FactoryBot.create(:application)
    end

    context "valid request" do
      should "update the application" do
        put :update, params: { id: @app.id, application: { name: "new name", deploy_freeze: true } }
        @app.reload
        assert_equal "new name", @app.name
        assert @app.deploy_freeze?
      end

      should "redirect to the application" do
        put :update, params: { id: @app.id, application: { name: "new name", deploy_freeze: true } }
        assert_redirected_to application_path(@app)
      end
    end

    context "invalid request" do
      should "render an error message" do
        put :update, params: { id: @app.id, application: { name: "" } }
        assert_select ".gem-c-error-summary__list-item", text: "Name is required"
      end

      should "rerender the form and respond with an unprocessable entity status" do
        put :update, params: { id: @app.id, application: { name: "" } }
        assert_template :edit
        assert_response :unprocessable_entity
      end
    end
  end

  context "GET deploy" do
    setup do
      stub_request(:get, Repo::REPO_JSON_URL).to_return(status: 200)
      @app = FactoryBot.create(:application, name: "app1", status_notes: "Do not deploy this without talking to core team first!")
      @deployment = FactoryBot.create(:deployment, application_id: @app.id, created_at: "18/01/2013 11:57")
      @release_tag = "hot_fix_1"
      stub_request(:get, %r{grafana_hostname/api/dashboards/file/#{@app.shortname}.json}).to_return(status: 404)
      stub_request(:get, "https://api.github.com/repos/#{@app.repo_path}/tags").to_return(body: [])
      stub_request(:get, "https://api.github.com/repos/#{@app.repo_path}/commits").to_return(body: [])

      Octokit::Client.any_instance.stubs(:compare)
        .with(@app.repo_path, @deployment.version, @release_tag)
        .returns(stub("comparison", commits: [], base_commit: nil))
      Plek.any_instance
        .stubs(:external_url_for)
        .with("signon")
        .returns("https://signon_hostname")
      Plek.any_instance
        .stubs(:external_url_for)
        .with("grafana")
        .returns("https://grafana_hostname")
    end

    should "show that we are trying to deploy the release" do
      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".gem-c-title .gem-c-title__text", "Deploy #{@release_tag}"
      assert_select ".gem-c-title .gem-c-title__context", text: @app.name
    end

    should "indicate which releases are current and about to be deployed" do
      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".govuk-body", "Production is on #{@deployment.version} — deployed at 11am on 18 Jan 2013"
    end

    should "include status notes as a warning" do
      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".gem-c-notice", "Do not deploy this without talking to core team first!"
    end

    should "show deployment link" do
      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".gem-c-button[href=?]", "#{@app.repo_url}/actions/workflows/deploy.yml"
    end

    context "when there is a github API 404 error" do
      setup do
        Octokit::Client.any_instance.stubs(:compare)
          .with(@app.repo_path, @deployment.version, @release_tag)
          .raises(Octokit::NotFound.new)
      end

      should "show the error message" do
        get :deploy, params: { id: @app.id, tag: @release_tag }

        assert_select ".application-notice.help-notice" do
          assert_select "p", "Couldn't get data from GitHub:"
          assert_select "p", "Octokit::NotFound"
        end
      end
    end
  end

private

  def random_sha
    hex_chars = Enumerator.new do |yielder|
      loop { yielder << "0123456789abcdef".chars.to_a.sample }
    end
    hex_chars.take(40).join
  end

  def stub_commit
    {
      sha: random_sha,
      login: "winston",
      commit: { message: "Hi" },
    }
  end
end
