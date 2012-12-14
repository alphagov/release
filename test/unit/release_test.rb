require "test_helper"

class ReleaseTest < ActiveSupport::TestCase
  context "loading releases" do
    should "load previous releases, upcoming releases, and releases for today" do
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
    setup do
      @application_one = FactoryGirl.create(:application, name: "Smart Answers")
      @application_two = FactoryGirl.create(:application, name: "Frontend")

      @atts = {
        summary: "Major new feature",
        notes: "A few notes about this release",
        deploy_at: Time.parse("25-12-2012 13:00"),
        tasks_attributes: {
          "0" => { description: "Deploy new smart answer", version: "123", application_id: @application_one.id },
          "1" => { description: "Redirect old quick answer", version: "101", application_id: @application_two.id }
        },
      }
    end

    context "given a user" do
      should "be created successfully" do
        user = FactoryGirl.create(:user)

        release = Release.new(@atts)
        assert release.valid?

        release.save_as(user)
        assert release.persisted?
      end

      should "persist the user" do
        user = FactoryGirl.create(:user)

        release = Release.new(@atts)
        release.save_as(user)

        release.reload
        assert_equal user, release.user
      end
    end

    context "given valid attributes" do
      should "be created successfully" do
        release = Release.new(@atts)
        assert release.valid?

        release.save
        assert release.persisted?
      end

      should "have tasks" do
        release = Release.create!(@atts)

        assert_equal 2, release.tasks.size

        assert release.tasks.map(&:description).include?("Deploy new smart answer")
        assert release.tasks.map(&:description).include?("Redirect old quick answer")
      end

      should "have applications" do
        release = Release.create!(@atts)

        assert_equal 2, release.applications.size

        assert release.applications.map(&:name).include?("Frontend")
        assert release.applications.map(&:name).include?("Smart Answers")
      end

      should "not be 'released' by default" do
        release = Release.create!(@atts)

        refute release.released?
      end
    end

    should "not be valid if there are no tasks" do
      release = Release.new

      refute release.valid?
      assert release.errors.full_messages.include?("Tasks requires at least one task")
    end

    should "not be valid without a summary" do
      release = Release.new(@atts.merge(summary: ''))

      refute release.valid?
      assert release.errors.full_messages.include?("Summary can't be blank")
    end

    should "not be valid without a deploy_at time" do
      release = Release.new(@atts.merge(deploy_at: nil))

      refute release.valid?
      assert release.errors.full_messages.include?("Deploy at can't be blank")
    end

    should "not be valid when deploy_at has an invalid timestamp" do
      release = Release.new(@atts.merge(deploy_at: 'No time should be parsed from this'))

      refute release.valid?
      assert release.errors.keys.include?(:deploy_at)
    end
  end
end
