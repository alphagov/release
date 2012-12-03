require 'spec_helper'

describe "tasks/new.html.erb" do
  before do
    assign(:applications, [stub_model(Application, name: "A", repo: "a"),
                           stub_model(Application, name: "b", repo: "b")])
    assign(:task, stub_model(Task, application: Application.new(name: "existing app")))
    render
  end

  it "should have an empty form" do
    rendered.should have_selector("form") do |form|
      form.should have_selector("input", name: "task[name]", value: "")
      form.should have_selector("input", name: "task[description]", value: "")
      form.should have_select("application", selected: "Select an Application")
    end
  end
end
