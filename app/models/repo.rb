class Repo
  include HTTParty
  base_uri "docs.publishing.service.gov.uk"

  def self.all
    response ||= get("/apps.json")
    JSON.parse(response.body)
  rescue HTTParty::Error, JSON::ParserError => e
    Rails.logger.debug "Error fetching govuk repos: #{e.message}"
    []
  end

  def self.find_by(app_name:)
    all.find { |app| app["app_name"] == app_name.parameterize }
  end
end
