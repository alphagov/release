RSpec.describe SlackPosterJob, type: :job do
  include ActiveJob::TestHelper

  let(:fake_webhook_url) { "https://hooks.slack.com/services/T000/B00/XX" }

  describe "#perform" do
    before do
      stub_const("ENV", ENV.to_hash.merge("SLACK_WEBHOOK_URL" => fake_webhook_url))
    end

    it "sends a post request with default options" do
      stub_post = stub_request(:post, fake_webhook_url).with(
        body: {
          username: "Release app",
          icon_emoji: ":govuk:",
          mrkdwn: "true",
          text: "Hello",
          channel: "#testchannel",
        }.to_json,
      ).to_return(status: 200, body: "ok")

      described_class.perform_now("Hello", "#testchannel")

      expect(stub_post).to have_been_requested
    end

    it "sends a post request with valid custom options" do
      stub_post = stub_request(:post, fake_webhook_url).with(
        body: {
          username: "Release app",
          icon_emoji: ":badger:",
          mrkdwn: "true",
          text: "Hello",
          channel: "#testchannel",
        }.to_json,
      ).to_return(status: 200, body: "ok")

      described_class.perform_now("Hello", "#testchannel", { "icon_emoji" => ":badger:" })

      expect(stub_post).to have_been_requested
    end

    it "raises error when called with invalid options" do
      expect {
        described_class.perform_now(
          "Hello",
          "#testchannel",
          { "invalid_option" => "value" },
        )
        perform_enqueued_jobs
      }.to raise_error(RuntimeError, /Invalid options, only username, icon_emoji, mrkdown are permitted/)
    end
  end
end
