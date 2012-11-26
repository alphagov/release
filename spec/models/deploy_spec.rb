require 'spec_helper'

describe Deploy do
  describe "required fields" do
    let(:deploy) { Deploy.new }

    it "should not be valid" do
      deploy.should_not be_valid
    end

    it "should require an application" do
      deploy.should have(1).error_on(:application)
      deploy.errors.full_messages.should include("Application can't be blank")
    end

    it "should require a version" do
      deploy.should have(1).error_on(:version)
      deploy.errors.full_messages.should include("Version can't be blank")
    end
  end

  describe "building a valid Deploy object" do
    let(:application) { Application.new(name: "Release", repo: "https://github.com/alphagov/release") }

    before do
      application.save
    end

    it "should create a Deploy association" do
      application.deploys.size.should == 0
      application.deploys.create(version: "release_101")
      application.deploys.size.should == 1
    end
  end
end
