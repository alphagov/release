require "faraday"
require "json"

class Repo
  REPO_JSON_URL = "https://docs.publishing.service.gov.uk/apps.json".freeze

  def self.all
    Rails.cache.fetch("apps_json", expires_in: 12.hours) do
      JSON.parse(Faraday.new.get(REPO_JSON_URL).body)
    rescue Faraday::Error, JSON::ParserError => e
      Rails.logger.warn "Error fetching govuk repos: #{e.message}"
      [] # TODO: don't eat the error; raise a wrapped exception and let the caller decide.
    end
  end

  def self.find_by(app_name:)
    app_name = app_name.parameterize
    all.find { |app| app["app_name"] == app_name }
  end

  def self.url(app_name:)
    find_by(app_name:)&.dig("links", "repo_url")
  end

  def self.shortname(app_name:)
    find_by(app_name:)&.dig("shortname")
  end
end
