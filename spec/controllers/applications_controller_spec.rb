require 'spec_helper'

describe ApplicationsController do
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
end
