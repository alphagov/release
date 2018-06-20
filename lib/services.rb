module Services
  def self.github
    credentials = defined?(GITHUB_CREDENTIALS) ? GITHUB_CREDENTIALS : {}
    @client ||= Octokit::Client.new(credentials)
  end
end
