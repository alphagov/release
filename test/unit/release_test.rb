require "test_helper"

class ReleaseTest < ActiveSupport::TestCase
  context "loading releases" do
    should "load upcoming tasks" do
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

  context "creating a release" do
    should "not be valid if there are no tasks" do
      release = Release.new

      refute release.valid?
      assert release.errors.full_messages.include?("Tasks requires at least one task")
    end

    should "be valid with a single task" do
      release = Release.new

      release.tasks << FactoryGirl.build(:task)

      assert release.valid?
      assert release.errors.empty?
    end

    should "update the task release_id when appended to a release" do
      release = Release.new
      task = FactoryGirl.build(:task)

      release.tasks << task
      release.save

      assert_not_nil task.release
      assert_equal release.id, task.release_id
    end

    should "contain many applications" do
      application_one = FactoryGirl.create(:application)
      application_two = FactoryGirl.create(:application)

      task_one = FactoryGirl.build(:task, application: application_one)
      task_two = FactoryGirl.build(:task, application: application_two)

      release = Release.new
      release.tasks = [task_one, task_two]
      release.save

      refute release.applications.empty?
      assert_equal [application_one, application_two], release.applications.to_a
    end
  end
end
