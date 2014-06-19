require "test_helper"

class ApplicationsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET index" do
    setup do
      @app1 = FactoryGirl.create(:application, name: "app1", repo: "user/app1")
      @app2 = FactoryGirl.create(:application, name: "app2", repo: "user/app2")
      @app3 = FactoryGirl.create(:application, name: "app3", repo: "user/app3", archived: true)
      @deploy1 = FactoryGirl.create(:deployment,
        application: @app1,
        environment: "staging",
        version: "release_x")
    end

    should "list unarchived applications" do
      get :index
      assert_select "table tbody tr", count: 2
    end

    should "show the latest deploy to an environment" do
      get :index
      assert_select "table tbody tr td:nth-child(3)", /release_x/
    end

    should "provide a link to compare with master" do
      get :index
      assert_select "table a[href=?]", "https://mygithub.tld/user/app1/compare/release_x...master"
    end

    should "provide a title attribute to sort environment columns by date" do
      get :index
      assert_select "table td[title=?]", @deploy1.created_at
    end
  end

  context "GET new" do
    should "render the form" do
      get :new
      assert_select "form input#application_name"
    end
  end

  context "POST create" do
    should "create an application" do
      assert_difference "Application.count", 1 do
        post :create, application: {
          name: "My First App",
          repo: "org/my_first_app",
          domain: "github.baz"
        }
      end
    end

    context "invalid request" do
      should "rerender the form" do
        post :create, application: { name: "", repo: "org/my_first_app" }
        assert_select "form input#application_name"
        assert_select "form input#application_repo[value='org/my_first_app']"
      end
    end
  end

  context "GET show" do
    setup do
      @app = FactoryGirl.create(:application)
      stub_request(:get, "https://api.github.com/repos/#{@app.repo}/tags").to_return(body: {})
      stub_request(:get, "https://api.github.com/repos/#{@app.repo}/commits").to_return(body: {})
    end

    should "show the application" do
      get :show, id: @app.id
      assert_select "h1 span.name", @app.name
    end

    context "GET show with a production deployment" do
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
            message: "Hi"
          }
        }
      end

      setup do
        version = "release_42"
        FactoryGirl.create(:deployment, application: @app, version: version)
        @first_commit, @second_commit = stub_commit, stub_commit
        @base_commit = stub_commit
        Octokit::Client.any_instance.stubs(:compare)
          .with(@app.repo, version, "master")
          .returns(stub("comparison",
                        commits: [@first_commit, @second_commit],
                        base_commit: @base_commit))
      end

      should "show the application" do
        get :show, id: @app.id
        assert_select "h1 span.name", @app.name
      end

      should "set the commit history in reverse order" do
        get :show, id: @app.id

        # `assigns` in Rails silently converts hashes to
        # HashWithIndifferentAccess instances, so we can't simply compare for
        # equality on the objects themselves
        assert_equal(
          [@second_commit[:sha], @first_commit[:sha]],
          assigns[:commits].take(2).map { |commit| commit[:sha] }
        )
      end

      should "include the base commit" do
        get :show, id: @app.id

        assert_equal @base_commit[:sha], assigns[:commits].last[:sha]
      end
    end
  end

  context "GET edit" do
    setup do
      @app = FactoryGirl.create(:application, name: "monkeys", repo: "org/monkeys")
    end

    should "show the form" do
      get :edit, id: @app.id
      assert_select "form input#application_name[value='#{@app.name}']"
    end

    should "allow editing of the shortname in the form" do
      get :edit, id: @app.id
      assert_select "form input#application_shortname[placeholder='#{@app.shortname}']"
    end
  end

  context "PUT update" do
    setup do
      @app = FactoryGirl.create(:application)
    end

    should "update the application" do
      put :update, id: @app.id, application: { name: "new name", repo: "new/repo" }
      @app.reload
      assert_equal "new name", @app.name
    end

    context "invalid request" do
      should "rerender the form" do
        put :update, id: @app.id, application: { name: "", repo: "new/repo" }
        @app.reload
        assert_redirected_to edit_application_path(@app)
      end
    end
  end

  context "PUT update_notes" do
    setup do
      @app = FactoryGirl.create(:application)
    end

    should "update the application, redirect to /applications" do
      put :update_notes, id: @app.id, application: { status_notes: "Rolled back deploy because science." }
      @app.reload
      assert_equal "Rolled back deploy because science.", @app.status_notes
      assert_redirected_to "/applications"
    end
  end

  context "GET archived" do
    setup do
      @app1 = FactoryGirl.create(:application, name: "app1", repo: "user/app1")
      @app2 = FactoryGirl.create(:application, name: "app2", repo: "user/app2")
      @app3 = FactoryGirl.create(:application, name: "app3", repo: "user/app3", archived: true)
    end

    should "show only archived applications" do
      get :archived
      assert_select "table tbody tr", count: 1
    end
  end
end
