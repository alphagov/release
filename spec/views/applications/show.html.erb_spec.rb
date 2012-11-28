require 'spec_helper'

describe "applications/show.html.erb" do
  before do
    assign(:application, stub_model(Application, name: "rails", repo: "https://github.com/rails/rails"))
    render
  end

  it "should display the application name" do
    rendered.should include("rails")
  end

  it "should display the application repo" do
    rendered.should include("https://github.com/rails/rails")
  end

  it "should have an 'edit' link" do
    rendered.should have_link("Edit")
  end

  it "should have a 'create deploy' link" do
    rendered.should have_link("Create Deploy")
  end
end
