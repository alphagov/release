require 'spec_helper'

describe "releases/edit.html.erb" do
  before do
    assign(:release, stub_model(Release, notes: "some random notes"))
    render
  end

  it "should have a form with all of the details filled out" do
    rendered.should have_selector("form") do |form|
      form.should have_selector("input", name: "release[notes]", value: "some random notes")
    end
  end
end
