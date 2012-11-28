require 'spec_helper'

describe Release do
  let(:application) { Application.new(name: "app for release test") }
  let(:task) { application.tasks.build(version: "release 101") }

  before do
    application.save
    task.save
  end

  describe "object creation" do
    it "should error if there are no tasks" do
      release = Release.new

      release.should_not be_valid
      release.errors.full_messages.should include("Tasks requires at least one task")
    end

    it "should be valid if there is a single task" do
      release = Release.new

      release.tasks << task

      release.should be_valid
      release.errors.should be_empty
    end

    it "should update the task release_id when appending to a release" do
      release = Release.new
      release.tasks << task
      release.save

      task.release.should_not be_nil
      task.release_id.should eq(release.id)
    end

    it "should contain many applications" do
      application_2 = Application.new(name: "Second App")
      application_2.save

      task_2 = application_2.tasks.build(version: "1234567")
      task_2.save

      release = Release.new
      release.tasks = [task, task_2]
      release.save

      release.applications.should_not be_empty
      release.applications.should include(application, application_2)
    end
  end
end
