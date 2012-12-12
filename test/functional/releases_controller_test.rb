require "test_helper"

class ReleasesControllerTest < ActionController::TestCase
  setup do
    login_as_stub_user
  end

  context "GET index" do
    setup do
      @release1 = FactoryGirl.create(:release)
      @release2 = FactoryGirl.create(:release)
    end

    should "list releases" do
      get :index
      assert_select "table tbody tr", count: 2
    end
  end

  context "GET new" do
    should "render the form" do
      get :new
      assert_template "releases/new"
    end
  end

  context "POST create" do
    setup do
      @app = FactoryGirl.create(:application)
    end

    should "create an release" do
      assert_difference "Release.count", 1 do
        post :create, release: { notes: "My First App", tasks_attributes: { "0" => { description: "Description", version: "123", application_id: @app.id } } }
      end    
    end
  end

  context "GET show" do
    setup do
      @release = FactoryGirl.create(:release)
    end

    should "show the release" do
      get :show, id: @release.id
      assert_select "h1", "Release #{@release.id}"
    end
  end

  context "GET edit" do
    setup do
      @release = FactoryGirl.create(:release)
    end

    should "show the form" do
      get :edit, id: @release.id
      assert_template "releases/edit"
    end
  end

  context "PUT update" do
    setup do
      @release = FactoryGirl.create(:release)
    end

    should "update the release" do
      put :update, id: @release.id, release: { notes: "New notes" }
      @release.reload
      assert_equal "New notes", @release.notes
    end
  end
end
