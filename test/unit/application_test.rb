require 'test_helper'

class ApplicationTest < ActiveSupport::TestCase
  include ApplicationHelper

  context "creating an application" do
    setup do
      @atts = {
        name: "Tron-o-matic",
        repo: "alphagov/tron-o-matic",
        domain: "github.foo"
      }
    end

    context "given valid attributes" do
      should "be created successfully" do
        application = Application.new(@atts)
        assert application.valid?

        application.save
        assert application.persisted?
      end
    end

    should "be invalid with an empty name" do
      application = Application.new(@atts.merge(:name => ""))

      refute application.valid?
    end

    should "be invalid with a duplicate name" do
      FactoryGirl.create(:application, :name => "Tron-o-matic")
      application = Application.new(@atts)

      refute application.valid?
      assert application.errors[:name].include?("has already been taken")
    end

    should "be invalid with a duplicate repo" do
      FactoryGirl.create(:application, :repo => "alphagov/tron-o-matic")
      application = Application.new(@atts)

      refute application.valid?
      assert application.errors[:repo].include?("has already been taken")
    end

    should "be invalid with an invalid repo" do
      application = Application.new(@atts)

      application.repo = "noslashes"
      refute application.valid?
      assert application.errors[:repo].include?("is invalid")

      application.repo = "too/many/slashes"
      refute application.valid?
      assert application.errors[:repo].include?("is invalid")

      application.repo = "/slashatfront"
      refute application.valid?
      assert application.errors[:repo].include?("is invalid")

      application.repo = "slashatback/"
      refute application.valid?
      assert application.errors[:repo].include?("is invalid")
    end

    should "use the second half of the repo name as shortname if shortname not provided or empty" do
      application = Application.new(@atts)
      assert_equal "tron-o-matic", application.shortname

      application.shortname = ""
      assert_equal "tron-o-matic", application.shortname
    end

    should "use the provided shortname if not empty" do
      application = Application.new(@atts.merge(:shortname => "giraffe"))
      assert_equal "giraffe", application.shortname
    end

    should "know its location on the internet" do
      application = Application.new(@atts)

      assert_equal "https://github.foo/alphagov/tron-o-matic", application.repo_url
    end

    should "default to not being archived" do
      @atts.delete :archived
      application = Application.new(@atts)

      assert_equal false, application.archived
    end
  end

  context "display datetimes" do
    should "use the word today if the release was today" do
      assert_equal "10:02am today",
                   human_datetime(DateTime.now.change(hour: 10, min: 2))
    end

    should "show a year if the date is old" do
      assert_equal "2pm on 3 Jul 2010",
                   human_datetime(DateTime.now.change(year: 2010, month: 7, day: 3, hour: 14))
    end
  end

  context "application releases" do
    setup do
      @application = FactoryGirl.create(:application)
    end

    should "have a list of releases given a task" do
      release = FactoryGirl.build(:release)
      release.tasks << FactoryGirl.build(:task, :application => @application)
      release.save!

      assert_equal 1, @application.releases.size
      assert_equal release.id, @application.releases.first.id
    end
  end
end
