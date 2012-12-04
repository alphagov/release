require 'spec_helper'

describe "tasks/index.html.erb" do
  let(:slicer) { Application.new(name: "slicer", repo: "slicer.com") }
  let(:dicer) { Application.new(name: "dicer", repo: "dicer.com") }
  let(:three_days) { 3.days.from_now }
  let(:four_days) { 4.days.from_now }

  before do
    slicer.save
    dicer.save

    assign(:tasks, [
      stub_model(Task, application: slicer, version: "release_101", created_at: three_days),
      stub_model(Task, application: dicer, version: "build-3522", created_at: four_days)
    ])

    render
  end

  it "should display links to the parent applications" do
    rendered.should have_link(slicer.name, href: url_for(slicer))
    rendered.should have_link(dicer.name, href: url_for(dicer))
  end

  it "should display the created at date" do
    rendered.should have_content(three_days)
    rendered.should have_content(four_days)
  end

  it "should have the task versions" do
    rendered.should have_content("release_101")
    rendered.should have_content("build-3522")
  end

  it "should have a link to create 'new' Deploy Tasks" do
    rendered.should have_link("Create Deploy Task", href: new_task_path)
  end
end
