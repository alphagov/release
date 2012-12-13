require 'test_helper'

class ApplicationTest < ActiveSupport::TestCase
  context "creating an application" do
    setup do
      @atts = { :name => "Tron-o-matic", repo: "alphagov/tron-o-matic" }
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
