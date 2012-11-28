require 'spec_helper'

describe "tasks/show.html.erb" do
  before do
    assign(:task, stub_model(Task, application: Application.new(name: "dead app"),
                                   version: "a_milli", description: "bleh"))
    render
  end

  it "should display the application name" do
    rendered.should include("dead app")
  end

  it "should display the task version" do
    rendered.should include("a_milli")
  end

  it "should have an 'edit' link" do
    rendered.should have_link("Edit")
  end
end
