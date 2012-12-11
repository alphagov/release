require "spec_helper"
require "github"

class Tag
  attr_accessor :name

  def initialize(name)
    @name = name
  end
end

describe Github do
  describe "create_from_config" do
    before(:each) do
      @config_path = "/tmp/release-tool-github-credentials.yml"
      credentials = <<eos
login: alphagov-release
oauth_token: blah-token
eos
      File.open(@config_path, "w+") {|f| f.write(credentials)}
    end

    after(:each) do
      File.unlink(@config_path) if File.exists?(@config_path)
    end

    it "should create an instance from a yaml configuration" do
      Octokit.should_receive(:new).with(login: "alphagov-release", oauth_token: "blah-token")

      Github.create_from_config(@config_path)
    end

    it "should raise an error if the config file does not exist" do
      File.unlink(@config_path)

      lambda { Github.create_from_config(@config_path) }.should raise_error
    end
  end

  describe "tags" do
    before(:each) do
      @octokit = mock(Octokit)
      Octokit.should_receive(:new).and_return(@octokit)
    end

    it "should list matching tags for a repo" do
      @octokit.should_receive(:tags)
              .with("example/example")
              .and_return(
                %w(my_tag your_tag their_tag our_tag).map {|name| Tag.new(name)}
              )

      Github.new
            .tags("example/example", "our")
            .should == %w(our_tag your_tag)
    end
  end
end