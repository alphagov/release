class Repo
  include HTTParty
  base_uri "docs.publishing.service.gov.uk"

  def self.all
    Rails.cache.fetch("apps_json_data", expires_in: 12.hours) do
      response ||= get("/apps.json")
      JSON.parse(response.body)
    rescue HTTParty::Error, JSON::ParserError => e
      Rails.logger.debug "Error fetching govuk repos: #{e.message}"
      []
    end
  end

  def self.find_by(app_name:)
    all.find { |app| app["app_name"] == app_name.parameterize }
  end

  def self.url(app_name:)
    find_by(app_name:)&.dig("links", "repo_url")
  end
end
