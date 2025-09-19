require "rake"

RSpec.describe "Post Out Of Syc Deploys Task", type: :task do
  include ActiveJob::TestHelper

  describe "post_out_of_sync_deploys" do
    it "enqueues the PostOutOfSyncDeploysJob" do
      expect {
        Rake::Task["post_out_of_sync_deploys"].invoke
      }.to have_enqueued_job(PostOutOfSyncDeploysJob)
    end
  end
end
