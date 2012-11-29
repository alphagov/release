require 'spec_helper'

describe "releases/show.html.erb" do
  before do
    assign(:release, stub_model(Release, id: 2, notes: "some silly notes"))
    render
  end

  it "should display the release number" do
    rendered.should include("Release 2")
  end

  it "should display the release notes" do
    rendered.should include("some silly notes")
  end

  it "should have an 'edit' link" do
    rendered.should have_link("Edit")
  end
end
