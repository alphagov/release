require 'spec_helper'

describe ReleasesController do
  let(:application) { Application.new(name: "dummy", repo: "somerepo.com") }
  let(:task) { application.tasks.build(version: "release_101") }
  let(:release) { Release.new }

  before do
    application.save
    task.save

    release.tasks << task
    release.save
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
      get :show, id: release.id
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
    describe "a non-existant Release record" do
      before(:each) do
        get :edit, id: 10000000000
      end

      it "should have a status of 404" do
        response.code.should eq("404")
      end
    end

    describe "an existing Release record" do
      before(:each) do
        get :edit, id: release.id
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
    xit "Need to work out how to pass in Task id's as an Array"
  end

  describe "update" do
    describe "post request with a non-existent id" do
      before(:each) do
        put :update, id: 1000000000, release: { notes: "does_not_compute" }
      end

      it "should show a 404" do
        response.code.should eq("404")
      end
    end

    describe "post request with a specific id" do
      before(:each) do
        put :update, id: release.id, release: { notes: "released some version" }
      end

      it "should redirect to the show page" do
        response.code.should eq("302")
        response.should redirect_to(action: "show", id: release.id)
      end
    end
  end
end
