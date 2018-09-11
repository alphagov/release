module Services
  def self.github
    credentials = defined?(GITHUB_CREDENTIALS) ? GITHUB_CREDENTIALS : {}
    @github ||= Octokit::Client.new(credentials)
  end
end
