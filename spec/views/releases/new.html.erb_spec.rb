require 'spec_helper'

describe "releases/new.html.erb" do
  before do
    assign(:release, stub_model(Release))
    render
  end

  it "should have an empty form" do
    rendered.should have_selector("form") do |form|
      form.should have_selector("input", name: "release[name]", value: "")
      form.should have_selector("input", name: "release[description]", value: "")
    end
  end
end
