require 'spec_helper'

describe "releases/index.html.erb" do
  let(:application) { Application.new(name: "Dummy App", repo: "dummyapp.com") }
  let(:application_2) { Application.new(name: "Dummy App 2", repo: "dummyapp2.com") }

  let(:task) { application.tasks.build(version: "456") }
  let(:task_2) { application_2.tasks.build(version: "789") }

  let(:three_days) { 3.days.from_now }
  let(:four_days) { 4.days.from_now }

  before do
    application.save
    application_2.save

    task.save
    task_2.save

    assign(:releases, [
      stub_model(Release, id: 1, tasks: [task], notes: "notes 1", created_at: three_days),
      stub_model(Release, id: 2, tasks: [task_2], notes: "notes 2", created_at: four_days)
    ])

    render
  end

  it "should display the release date" do
    rendered.should have_content(three_days)
    rendered.should have_content(four_days)
  end

  it "should display the application names for a given release" do
    rendered.should have_content(application.name)
    rendered.should have_content(application_2.name)
  end

  it "should have a link to create 'new' Releases" do
    rendered.should have_link("Create Release", href: new_release_path)
  end
end
