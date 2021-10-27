require "test_helper"

class ApplicationsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET index" do
    setup do
      @app1 = FactoryBot.create(:application, name: "app1", repo: "user/app1", default_branch: "main")
      @app2 = FactoryBot.create(:application, name: "app2", repo: "user/app2")
      @app3 = FactoryBot.create(:application, name: "app3", repo: "user/app3", archived: true)
      @deploy1 = FactoryBot.create(
        :deployment,
        application: @app1,
        environment: "staging",
        version: "release_x",
      )
    end

    should "list unarchived applications" do
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
    context "valid request" do
      should "create an application" do
        assert_difference "Application.count", 1 do
          post :create,
               params: {
                 application: {
                   name: "My First App",
                   repo: "org/my_first_app",
                 },
               }
        end
      end

      should "redirect to the application" do
        post :create,
             params: {
               application: {
                 name: "My First App",
                 repo: "org/my_first_app",
               },
             }
        assert_redirected_to application_path(Application.last)
      end
    end

    context "invalid request" do
      should "render an error message" do
        post :create, params: { application: { name: "", repo: "org/my_first_app" } }
        assert_select ".gem-c-error-summary__list-item", text: "Name is required"
      end

      should "rerender the form and respond with an unprocessable entity status" do
        post :create, params: { application: { name: "", repo: "org/my_first_app" } }
        assert_template :new
        assert_response :unprocessable_entity
      end
    end
  end

  context "GET show" do
    setup do
      @app = FactoryBot.create(:application)
      stub_request(:get, "https://api.github.com/repos/#{@app.repo}/tags").to_return(body: [])
      stub_request(:get, "https://api.github.com/repos/#{@app.repo}/commits").to_return(body: [])

      Octokit::Client.any_instance.stubs(:search_issues)
        .with("repo:#{@app.repo} is:pr state:open label:dependencies")
        .returns({
          "total_count": 5,
        })
    end

    should "show the application name" do
      get :show, params: { id: @app.id }
      assert_select ".gem-c-title .gem-c-title__text", text: "Deploy #{@app.name}"
    end

    should "show the application shortname" do
      get :show, params: { id: @app.id }
      assert_select ".gem-c-title .gem-c-title__context", text: @app.shortname
    end

    should "show the CD status" do
      get :show, params: { id: @app.id }
      assert_select ".release__badge--orange", "Manually deployed"
      assert_select ".release__badge", { text: "Continuously deployed", count: 0 }

      Application.stub :cd_statuses, { @app.shortname => { continuously_deployed: true } } do
        get :show, params: { id: @app.id }
        assert_select ".release__badge", "Continuously deployed"
        assert_select ".release__badge--orange", false
      end
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

    context "GET show with a production deployment" do
      setup do
        version = "release_42"
        FactoryBot.create(:deployment, application: @app, version: version)
        @first_commit = stub_commit
        @second_commit = stub_commit
        @base_commit = stub_commit
        Octokit::Client.any_instance.stubs(:compare)
          .with(@app.repo, version, @app.default_branch)
          .returns(stub(
                     "comparison",
                     commits: [@first_commit, @second_commit],
                     base_commit: @base_commit,
                   ))
      end

      should "show the application" do
        get :show, params: { id: @app.id }
        assert_select ".gem-c-title .gem-c-title__text", text: "Deploy #{@app.name}"
      end

      should "set the commit history in reverse order" do
        get :show, params: { id: @app.id }

        # `assigns` in Rails silently converts hashes to
        # HashWithIndifferentAccess instances, so we can't simply compare for
        # equality on the objects themselves
        assert_equal(
          [@second_commit[:sha], @first_commit[:sha]],
          assigns[:commits].take(2).map { |commit| commit[:sha] },
        )
      end

      should "include the base commit" do
        get :show, params: { id: @app.id }

        assert_equal @base_commit[:sha], assigns[:commits].last[:sha]
      end
    end

    context "when format is json" do
      setup do
        @app = FactoryBot.create(:application, name: "Application 1", repo: "alphagov/application-1")
      end

      should "return a successful response" do
        get :show, params: { id: @app.id }, format: :json
        body = JSON.parse(response.body)

        assert_response :success
        assert_equal "application/json", response.media_type

        assert_equal "Application 1", body["name"]
        assert_equal "application-1", body["shortname"]
        assert_equal "", body["notes"]
        assert_equal false, body["archived"]
        assert_equal false, body["deploy_freeze"]
        assert_equal false, body["hosted_on_aws"]
        assert_equal "https://github.com/alphagov/application-1", body["repository_url"]
      end
    end

    context "when there is a github API 404 error" do
      setup do
        stub_request(:get, "https://api.github.com/repos/#{@app.repo}/tags").to_raise(Octokit::NotFound.new)
        get :show, params: { id: @app.id }
      end

      should "show the error message" do
        assert_select ".application-notice.help-notice" do
          assert_select "p", "Couldn't get data from GitHub:"
          assert_select "p", "Octokit::NotFound"
        end
      end
    end

    context "when there is a github rate limit error" do
      setup do
        stub_request(:get, "https://api.github.com/repos/#{@app.repo}/tags").to_raise(Octokit::TooManyRequests.new)
        stub_request(:get, "https://api.github.com/rate_limit").to_return(
          headers: { "X-RateLimit-Reset" => 5.minutes.from_now.to_i },
          body: "",
        )
        get :show, params: { id: @app.id }
      end

      should "show the rate limit message" do
        assert_select ".application-notice.help-notice" do
          assert_select "p", "Couldn't get data from GitHub:"
        end
      end
    end

    context "when there is another github error" do
      setup do
        stub_request(:get, "https://api.github.com/repos/#{@app.repo}/tags").to_raise(Octokit::Error.new)
        get :show, params: { id: @app.id }
      end

      should "show the error message" do
        assert_select ".application-notice.help-notice" do
          assert_select "p", "Couldn't get data from GitHub:"
          assert_select "p", "Octokit::Error"
        end
      end
    end
  end

  context "GET edit" do
    setup do
      @app = FactoryBot.create(:application, name: "monkeys", repo: "org/monkeys")
    end

    should "show the form" do
      get :edit, params: { id: @app.id }
      assert_select "form.edit_application input[name='application[name]'][value='#{@app.name}']"
    end

    should "allow editing of the shortname in the form" do
      get :edit, params: { id: @app.id }
      assert_select "form.edit_application input[name='application[shortname]'][value='#{@app.shortname}']"
    end
  end

  context "PUT update" do
    setup do
      @app = FactoryBot.create(:application)
    end

    context "valid request" do
      should "update the application" do
        put :update, params: { id: @app.id, application: { name: "new name", repo: "new/repo", on_aws: true, deploy_freeze: true } }
        @app.reload
        assert_equal "new name", @app.name
        assert_equal true, @app.on_aws?
        assert_equal true, @app.deploy_freeze?
      end

      should "redirect to the application" do
        put :update, params: { id: @app.id, application: { name: "new name", repo: "new/repo", on_aws: true, deploy_freeze: true } }
        assert_redirected_to application_path(@app)
      end
    end

    context "invalid request" do
      should "render an error message" do
        put :update, params: { id: @app.id, application: { name: "", repo: "new/repo" } }
        assert_select ".gem-c-error-summary__list-item", text: "Name is required"
      end

      should "rerender the form and respond with an unprocessable entity status" do
        put :update, params: { id: @app.id, application: { name: "", repo: "new/repo" } }
        assert_template :edit
        assert_response :unprocessable_entity
      end
    end
  end

  context "GET archived" do
    setup do
      @app1 = FactoryBot.create(:application, name: "app1", repo: "user/app1")
      @app2 = FactoryBot.create(:application, name: "app2", repo: "user/app2")
      @app3 = FactoryBot.create(:application, name: "app3", repo: "user/app3", archived: true)
    end

    should "show only archived applications" do
      get :archived
      assert_select ".gem-c-table .govuk-table__body .govuk-table__row", count: 1
    end
  end

  context "GET deploy" do
    setup do
      @app = FactoryBot.create(:application, status_notes: "Do not deploy this without talking to core team first!")
      @deployment = FactoryBot.create(:deployment, application_id: @app.id, created_at: "18/01/2013 11:57")
      @release_tag = "hot_fix_1"
      stub_request(:get, %r{grafana_hostname/api/dashboards/file/#{@app.shortname}.json}).to_return(status: 404)
      stub_request(:get, "https://api.github.com/repos/#{@app.repo}/tags").to_return(body: [])
      stub_request(:get, "https://api.github.com/repos/#{@app.repo}/commits").to_return(body: [])
      Octokit::Client.any_instance.stubs(:compare)
        .with(@app.repo, @deployment.version, @release_tag)
        .returns(stub(
                   "comparison",
                   commits: [],
                   base_commit: nil,
                 ))
      Plek.any_instance
        .stubs(:external_url_for)
        .with("signon")
        .returns("https://signon_hostname")

      Plek.any_instance
        .stubs(:external_url_for)
        .with("grafana")
        .returns("https://grafana_hostname")
    end

    should "show that we are trying to deploy the application" do
      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".gem-c-title .gem-c-title__text", "Deploy #{@app.name}"
    end

    should "indicate which releases are current and about to be deployed" do
      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".gem-c-heading", "Candidate Release: #{@release_tag}"
      assert_select ".govuk-body", "Production is on #{@deployment.version} — deployed at 11am on 18 Jan 2013"
    end

    should "include status notes as a warning" do
      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".gem-c-notice", "Do not deploy this without talking to core team first!"
    end

    should "show dashboard links to application's deployment dashboard" do
      @app.shortname = "whitehall"
      @app.save!
      stub_request(:get, "https://grafana_hostname/api/dashboards/file/whitehall.json").to_return(status: "200")

      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".govuk-link[href=?]", "https://grafana.publishing.service.gov.uk/dashboard/file/whitehall.json"
      assert_select ".govuk-link[href=?]", "https://grafana.staging.publishing.service.gov.uk/dashboard/file/whitehall.json"
    end

    should "show Carrenza links when application is not on AWS" do
      @app.update!(on_aws: false)

      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".gem-c-button[href=?]", "https://deploy.staging.publishing.service.gov.uk/job/Deploy_App/parambuild?TARGET_APPLICATION=#{@app.shortname}&TAG=hot_fix_1"
      assert_select ".gem-c-button[href=?]", "https://deploy.publishing.service.gov.uk/job/Deploy_App/parambuild?TARGET_APPLICATION=#{@app.shortname}&TAG=hot_fix_1"
    end

    should "show AWS links when application is on AWS" do
      @app.update!(on_aws: true)

      get :deploy, params: { id: @app.id, tag: @release_tag }
      assert_select ".gem-c-button[href=?]", "https://deploy.blue.staging.govuk.digital/job/Deploy_App/parambuild?TARGET_APPLICATION=#{@app.shortname}&TAG=hot_fix_1"
      assert_select ".gem-c-button[href=?]", "https://deploy.blue.production.govuk.digital/job/Deploy_App/parambuild?TARGET_APPLICATION=#{@app.shortname}&TAG=hot_fix_1"
    end

    context "when there is a github API 404 error" do
      setup do
        Octokit::Client.any_instance.stubs(:compare)
          .with(@app.repo, @deployment.version, @release_tag)
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
      commit: {
        message: "Hi",
      },
    }
  end
end
