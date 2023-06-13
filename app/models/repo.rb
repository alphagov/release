class Repo
  include HTTParty
  base_uri "docs.publishing.service.gov.uk"

  def self.all
    response ||= get("/repos.json")
    JSON.parse(response.body)
  rescue HTTParty::Error, JSON::ParserError => e
    Rails.logger.debug "Error fetching govuk repos: #{e.message}"
    []
  end
end
