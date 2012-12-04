require 'spec_helper'

describe "releases/new.html.erb" do
  let(:application) { stub_model(Application, name: "Dummy", repo: "dummy.com") }

  before do
    assign(:release, stub_model(Release))
    assign(:tasks, [stub_model(Task, application: application, version: "release_203"),
                    stub_model(Task, application: application, version: "release_202"),
                    stub_model(Task, application: application, version: "release_201")])

    render
  end

  it "should have an empty form" do
    rendered.should have_selector("form") do |form|
      form.should have_selector("input", name: "release[name]", value: "")
      form.should have_selector("input", name: "release[description]", value: "")
    end
  end

  it "should have a list of tasks" do
    rendered.should have_content("Dummy - release_201")
    rendered.should have_content("Dummy - release_202")
    rendered.should have_content("Dummy - release_203")
  end
end
