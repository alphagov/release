require 'spec_helper'

describe "applications/new.html.erb" do
  before do
    assign(:application, stub_model(Application))
    render
  end

  it "should have an empty form" do
    rendered.should have_selector("form") do |form|
      form.should have_selector("input", name: "application[name]", value: "")
      form.should have_selector("input", name: "application[repo]", value: "")
    end
  end
end
