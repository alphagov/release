require 'spec_helper'

describe "applications/show.html.erb" do
  before do
    assign(:application, stub_model(Application, name: "rails", repo: "https://github.com/rails/rails"))
    render
  end

  it "should display the application" do
    rendered.should include("rails")
  end

  it "should have a form with the relevant fields filled out" do
    rendered.should have_selector("form") do |form|
      form.should have_selector("input", name: "application[name]", value: "rails")
      form.should have_selector("input", name: "application[repo]", value: "https://github.com/rails/rails")
    end
  end
end
