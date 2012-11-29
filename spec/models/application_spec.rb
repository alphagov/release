require 'spec_helper'

describe Application do
  before do
    Application.create!(name: "Foo", repo: "foo.com")
  end

  it "should require a name to be present" do
    Application.new.should_not be_valid
  end

  it "should have an error message when a name is not provided" do
    application = Application.new

    application.should have(1).error_on(:name)
    application.errors.full_messages.should include("Name is required")
  end

  it "should not allow an empty name" do
    Application.new(name: "").should_not be_valid
  end

  it "should not allow creation of an application with the same name" do
    app = Application.new(name: "Foo")

    app.should_not be_valid
    app.errors[:name].should include("has already been taken")
  end

  it "should not allow creation of an application with the same repo" do
    app = Application.new(name: "Bar", repo: "foo.com")

    app.should_not be_valid
    app.errors[:repo].should include("has already been taken")
  end

  describe "valid object" do
    let(:application) { Application.new(name: "Release", repo: "release.com") }
    let(:task) { application.tasks.build(version: "release 23434") }

    before do
      application.save
      task.save
    end

    it "should build have no errors" do
      application.should be_valid
      application.should have(0).errors_on(:name)
    end

    it "should have a list of releases" do
      release = Release.new
      release.tasks << task
      release.save

      application.releases.should_not be_empty
      application.releases.size.should eq(1)
    end
  end
end
