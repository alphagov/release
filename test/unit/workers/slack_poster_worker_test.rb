require "test_helper"

class SlackPosterTest < ActiveSupport::TestCase
  context "#perform" do
    setup do
      @webhook_url = "https://hooks.slack.com/services/T000/B00/XXX"
    end

    should "enqueue a job" do
      assert_equal 0, SlackPosterWorker.jobs.size

      mock_env({ "SLACK_WEBHOOK_URL" => @webhook_url }) do
        SlackPosterWorker.perform_async("Hello", "#testchannel")
        assert_equal 1, SlackPosterWorker.jobs.size
      end
    end

    should "send a post request" do
      mock_env({ "SLACK_WEBHOOK_URL" => @webhook_url }) do
        stub_post = stub_request(:post, @webhook_url).with(
          body: "{\"username\":\"Release app\",\"icon_emoji\":\":govuk:\",\"mrkdwn\":\"true\",\"text\":\"Hello\",\"channel\":\"#testchannel\"}",
        ).to_return(status: 200, body: "ok", headers: {})

        SlackPosterWorker.perform_async("Hello", "#testchannel")
        SlackPosterWorker.drain

        assert_requested(stub_post)
      end
    end

    should "send a post request when called with vaild options" do
      mock_env({ "SLACK_WEBHOOK_URL" => @webhook_url }) do
        stub_post = stub_request(:post, @webhook_url).with(
          body: "{\"username\":\"Release app\",\"icon_emoji\":\":badger:\",\"mrkdwn\":\"true\",\"text\":\"Hello\",\"channel\":\"#testchannel\"}",
        ).to_return(status: 200, body: "ok", headers: {})

        SlackPosterWorker.perform_async("Hello", "#testchannel", { "icon_emoji" => ":badger:" })
        SlackPosterWorker.drain

        assert_requested(stub_post)
      end
    end

    should "not accept invalid options" do
      assert_raises(StandardError, 'Invalid options, only "username", "icon_emoji", "mrkdown" are permitted') do
        SlackPosterWorker.perform_async("Hello", "#testchannel", { "name" => "Slack poster", "icon_emoji" => ":badger:" })
        SlackPosterWorker.drain
      end
    end
  end
end
