require 'spec_helper'

describe "applications/index.html.erb" do
  it "displays all the applications" do
    assign(:applications, [
      stub_model(Application, name: "slicer"),
      stub_model(Application, name: "dicer")
    ])

    render

    rendered.should include("slicer")
    rendered.should include("dicer")
  end
end
