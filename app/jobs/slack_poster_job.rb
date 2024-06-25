require "faraday"

class SlackPosterJob < ApplicationJob
  queue_as :default
  retry_on Exception, attempts: 2

  VALID_OPTIONS = %w[username icon_emoji mrkdown].freeze

  def perform(text, channel, options = {})
    raise "Invalid options, only #{VALID_OPTIONS.join(', ')} are permitted" unless valid_options?(options)

    @webhook_url = ENV["SLACK_WEBHOOK_URL"]
    post_to_slack(payload(text, channel, options)) if @webhook_url.present?
  end

private

  class SlackMessageError < StandardError; end

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
    response = Faraday.new.post(@webhook_url, payload.to_json)

    unless response.success?
      raise SlackMessageError, "Slack error: #{response.body}"
    end
  end

  def valid_options?(options)
    options.keys.all? { |key| VALID_OPTIONS.include?(key) }
  end
end
