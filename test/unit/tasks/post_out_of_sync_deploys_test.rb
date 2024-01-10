require "test_helper"
require "rake"

class PostOutOfSyncDeploysTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  def setup
    ReleaseApp::Application.load_tasks if Rake::Task.tasks.empty?
  end

  test "it should run PostOutOfSyncDeploysJob" do
    assert_enqueued_with job: PostOutOfSyncDeploysJob do
      Rake.application.invoke_task "post_out_of_sync_deploys"
    end
  end
end
