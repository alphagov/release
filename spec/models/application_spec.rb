require 'spec_helper'

describe Application do
  it "should require a name to be present" do
    Application.new.should_not be_valid
  end

  it "should have an error message when a name is not provided" do
    application = Application.new

    application.should have(1).error_on(:name)
    application.errors.full_messages.should == ["Name is required"]
  end

  it "should not allow an empty name" do
    Application.new(name: "").should_not be_valid
  end

  it "should build out a valid Application with no errors" do
    application = Application.new(name: "Release")

    application.should be_valid
    application.should have(0).errors_on(:name)
  end
end
