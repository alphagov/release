require 'spec_helper'

describe "deploys/show.html.erb" do
  before do
    assign(:deploy, stub_model(Deploy, application: Application.new(name: "dead app"),
                                       version: "a_milli", description: "bleh"))
    render
  end

  it "should display the application name" do
    rendered.should include("dead app")
  end

  it "should display the deploy version" do
    rendered.should include("a_milli")
  end

  it "should have an 'edit' link" do
    rendered.should have_link("Edit")
  end
end
