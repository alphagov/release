require "test_helper"

class SlackPosterJobTest < ActiveJob::TestCase
  setup do
    @webhook_url = "https://hooks.slack.com/services/T000/B00/XXX"
  end

  should "send a post request" do
    mock_env({ "SLACK_WEBHOOK_URL" => @webhook_url }) do
      stub_post = stub_request(:post, @webhook_url).with(
        body: "{\"username\":\"Release app\",\"icon_emoji\":\":govuk:\",\"mrkdwn\":\"true\",\"text\":\"Hello\",\"channel\":\"#testchannel\"}",
      ).to_return(status: 200, body: "ok", headers: {})

      SlackPosterJob.perform_now("Hello", "#testchannel")

      assert_requested(stub_post)
    end
  end

  should "send a post request when called with vaild options" do
    mock_env({ "SLACK_WEBHOOK_URL" => @webhook_url }) do
      stub_post = stub_request(:post, @webhook_url).with(
        body: "{\"username\":\"Release app\",\"icon_emoji\":\":badger:\",\"mrkdwn\":\"true\",\"text\":\"Hello\",\"channel\":\"#testchannel\"}",
      ).to_return(status: 200, body: "ok", headers: {})

      SlackPosterJob.perform_now("Hello", "#testchannel", { "icon_emoji" => ":badger:" })

      assert_requested(stub_post)
    end
  end

  should "not accept invalid options" do
    perform_enqueued_jobs do
      assert_raises(StandardError, 'Invalid options, only "username", "icon_emoji", "mrkdown" are permitted') do
        SlackPosterJob.perform_later("Hello", "#testchannel", { "name" => "Slack poster", "icon_emoji" => ":badger:" })
      end
    end
  end
end
