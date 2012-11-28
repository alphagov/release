require 'spec_helper'

describe "deploys/new.html.erb" do
  before do
    assign(:deploy, stub_model(Deploy, application: Application.new(name: "existing app")))
    render
  end

  it "should have an empty form" do
    rendered.should have_selector("form") do |form|
      form.should have_selector("input", name: "deploy[name]", value: "")
      form.should have_selector("input", name: "deploy[description]", value: "")
    end
  end
end
