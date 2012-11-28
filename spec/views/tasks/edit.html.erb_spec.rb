require 'spec_helper'

describe "tasks/edit.html.erb" do
  before do
    assign(:task, stub_model(Task, application: Application.new(name: "dead app"),
                                   version: "a_milli", description: "bleh"))
    render
  end

  it "should have a form with all of the details filled out" do
    rendered.should have_selector("form") do |form|
      form.should have_selector("input", name: "task[version]", value: "a milli")
      form.should have_selector("input", name: "task[description]", value: "bleh")
    end
  end
end
