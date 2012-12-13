require 'test_helper'

class TaskTest < ActiveSupport::TestCase

  context "creating a task" do
    context "given an application" do
      setup do
        @application = FactoryGirl.create(:application)
      end

      context "given valid attributes" do
        setup do
          @atts = { :version => "123", :description => "Deploy all the things" }
        end

        should "be created successfully" do
          task = @application.tasks.build(@atts)
          assert task.valid?

          task.save
          assert task.persisted?
        end

        should "accept version as a string" do
          task = @application.tasks.build(@atts.merge(version: "release_123"))
          assert task.valid?
        end
      end

      should "be invalid without a version" do
        task = @application.tasks.build(:description => "Deploy some of the things")

        refute task.valid?
        assert task.errors[:version].include?("can't be blank")
      end
    end

    should "be invalid without an application" do
      task = Task.new(:description => "Deploy none of the things", :version => "12345")

      refute task.valid?
      assert task.errors[:application].include?("can't be blank")
    end
  end

end
