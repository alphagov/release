require "test_helper"

class ApplicationsControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET index" do
    setup do
      @app1 = FactoryGirl.create(:application, name: "app1", repo: "user/app1")
      @app2 = FactoryGirl.create(:application, name: "app2", repo: "user/app2")
      @deploy1 = FactoryGirl.create(:deployment,
        application: @app1,
        environment: "staging",
        version: "release_x")
    end

    should "list applications" do
      get :index
      assert_select "table tbody tr", count: 2
    end

    should "show the latest deploy to an environment" do
      get :index
      assert_select "table tbody tr td:nth-child(3)", /release_x/
    end

    should "provide a link to compare with master" do
      get :index
      assert_select "table a[href=?]", "https://github.com/user/app1/compare/release_x...master"
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
      stub_request(:get, "https://api.github.com/repos/#{@app.repo}/commits?per_page=35&sha=master").to_return(body: {})
    end

    should "show the application" do
      get :show, id: @app.id
      assert_select "h1 span.name", @app.name
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
end
