require 'spec_helper'

describe Task do
  describe "required fields" do
    let(:task) { Task.new }

    it "should not be valid" do
      task.should_not be_valid
    end

    it "should require an application" do
      task.should have(1).error_on(:application)
      task.errors.full_messages.should include("Application can't be blank")
    end

    it "should require a version" do
      task.should have(1).error_on(:version)
      task.errors.full_messages.should include("Version can't be blank")
    end
  end

  describe "building a valid Task object" do
    let(:application) { Application.new(name: "Release", repo: "https://github.com/alphagov/release") }

    before do
      application.save
    end

    it "should create a Task association" do
      application.tasks.size.should == 0
      application.tasks.create(version: "release_101")
      application.tasks.size.should == 1
    end
  end
end
