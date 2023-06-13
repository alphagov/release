require "httparty"

class SlackPosterWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  VALID_OPTIONS = %w[username icon_emoji mrkdown].freeze

  def perform(text, channel, options = {})
    raise "Invalid options, only #{VALID_OPTIONS.join(', ')} are permitted" unless valid_options?(options)

    @webhook_url = ENV["SLACK_WEBHOOK_URL"]

    post_to_slack(payload(text, channel, options)) if @webhook_url.present?
  end

private

  def payload(text, channel, options)
    {
      username: options["username"] || "Release app",
      icon_emoji: options["icon_emoji"] || ":govuk:",
      mrkdwn: options["mrkdwn"] || "true",
      text:,
      channel:,
    }
  end

  def post_to_slack(payload)
    response = HTTParty.post(@webhook_url, body: payload.to_json)

    unless successful?(response.code)
      raise SlackMessageError, "Slack error: #{response.body}"
    end
  end

  def successful?(response_code)
    success_response_code = 200
    response_code == success_response_code
  end

  def valid_options?(options)
    options.keys.all? { |key| VALID_OPTIONS.include?(key) }
  end

  class SlackMessageError < StandardError; end
end
