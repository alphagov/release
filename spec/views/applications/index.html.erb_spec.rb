require 'spec_helper'

describe "applications/index.html.erb" do
  before do
    assign(:applications, [
      stub_model(Application, name: "slicer"),
      stub_model(Application, name: "dicer")
    ])

    render
  end

  it "displays all the applications" do
    rendered.should include("slicer")
    rendered.should include("dicer")
  end

  it "should have a link to create 'new' Applications" do
    rendered.should have_link("Create Application", href: new_application_path)
  end
end
