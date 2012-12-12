require 'spec_helper'

describe Release do
  let(:application) { Application.new(name: "app for release test", repo: "appreleasetest.com") }
  let(:task) { application.tasks.build(version: "release 101") }

  before do
    application.save
    task.save
  end

  describe "loading releases" do
    it "should load upcoming tasks" do
      release_yesterday = FactoryGirl.create(:release, deploy_at: Time.parse('24-12-2012 13:30'), notes: "Yesterday")
      release_today = FactoryGirl.create(:release, deploy_at: Time.parse('25-12-2012 14:00'), notes: "Right now")
      release_tomorrow = FactoryGirl.create(:release, deploy_at: Time.parse('26-12-2012 13:30'), notes: "Tomorrow")

      Timecop.freeze(Date.parse('25 December 2012')) do
        assert_equal 1, Release.previous_releases.count
        assert_equal 1, Release.todays_releases.count
        assert_equal 1, Release.future_releases.count

        assert_equal "Yesterday", Release.previous_releases.first.notes
        assert_equal "Right now", Release.todays_releases.first.notes
        assert_equal "Tomorrow", Release.future_releases.last.notes
      end
    end
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
      application_2 = Application.new(name: "Second App", repo: "secondapp.com")
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
