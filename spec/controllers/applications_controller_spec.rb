require 'spec_helper'

describe ApplicationsController do
  before(:each) do
    login_as_stub_user
    Application.new(name: "dummy", repo: "somerepo.com").save
  end

  describe "index" do
    before(:each) do
      get :index
    end

    it "should load successfully" do
      response.code.should eq("200")
    end

    it "should load the 'index' template" do
      response.should render_template("index")
    end
  end

  describe "show" do
    before(:each) do
      get :show, id: 1
    end

    it "should load successfully" do
      response.code.should eq("200")
    end

    it "should load the 'show' template" do
      response.should render_template("show")
    end
  end

  describe "new" do
    before(:each) do
      get :new
    end

    it "should load successfully" do
      response.code.should eq("200")
    end

    it "should load the 'new' template" do
      response.should render_template("new")
    end
  end

  describe "edit" do
    describe "a non-existant Application record" do
      before(:each) do
        get :edit, id: 10000000000
      end

      it "should have a status of 404" do
        response.code.should eq("404")
      end
    end

    describe "an existing Application record" do
      before(:each) do
        get :edit, id: 1
      end

      it "should have a status of 200" do
        response.code.should eq("200")
      end

      it "should load the 'edit' template" do
        response.should render_template("edit")
      end
    end
  end

  describe "create" do
    describe "post request without a body" do
      before(:each) do
        post :create
      end

      it "should render the 'new' template" do
        response.should render_template("new")
      end
    end

    describe "post request with a body" do
      before(:each) do
        post :create, application: { name: "some app", repo: "somerepo.com/some_app"}
      end

      it "should redirect to the 'show' action" do
        response.code.should eq("302")
        response.should redirect_to(action: "show", id: "2")
      end
    end
  end

  describe "update" do
    describe "post request with a non-existent id" do
      before(:each) do
        put :update, id: 100000000
      end

      it "should show a 404" do
        response.code.should eq("404")
      end
    end

    describe "post request with a specific id" do
      before(:each) do
        put :update, id: 1
      end

      it "should redirect to the show page" do
        response.code.should eq("302")
        response.should redirect_to(action: "show", id: "1")
      end
    end
  end

  describe "tags" do
    describe "retrieve matching tags" do
      before(:each) do
        @github = mock()
        Github.should_receive(:new)
              .and_return(@github)
        @github.should_receive(:tags)
              .with("somerepo.com", "some term")
              .and_return(%w(release_1 release_2))

        get :tags, id: 1, term: "some term"
      end

      it "should load successfully" do
        response.code.should == "200"
      end

      it "should render json" do
        JSON.parse(response.body).should == %w(release_1 release_2)
      end
    end
  end
end
