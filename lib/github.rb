require "yaml"
require "octokit"

class Github


  def self.create_from_config(path)
    config = YAML.load_file(path)

    self.new(login: config["login"], oauth_token: config["oauth_token"])
  end

  def initialize(config={})
    @client = Octokit.new(config)
  end

  def tags(repo, term)
    @client.tags(repo)
           .map(&:name)
           .select {|tag| tag.include?(term) }
           .sort
  end
end