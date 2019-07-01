class Commit
  attr_reader :commit_data, :application

  def initialize(commit_data, application)
    @commit_data = commit_data.deep_symbolize_keys
    @application = application
  end

  def github_url
    "#{application.repo_url}/commit/#{commit_data[:sha]}"
  end

  def sha
    commit_data[:sha][0..8]
  end

  def title
    commit_data[:commit][:message].split(/\n/, 2).first
  end

  def pr?
    title.starts_with?("Merge pull request")
  end

  def author_avatar
    commit_data[:author] && commit_data[:author][:avatar_url]
  end

  def author_name
    commit_data[:author] && commit_data[:author][:login]
  end

  def commit_date
    commit_data[:commit][:author][:date].to_time # rubocop:disable Rails/Date
  end
end
