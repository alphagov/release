require "test_helper"
require "rake"

class PostOutOfSyncDeploysTest < ActiveSupport::TestCase
  def setup
    ReleaseApp::Application.load_tasks if Rake::Task.tasks.empty?
  end

  test "it should call PostOutOfSyncDeploysService" do
    post_out_of_sync_deploys_service_mock = Minitest::Mock.new
    post_out_of_sync_deploys_service_mock.expect(:call, nil)

    PostOutOfSyncDeploysService.stub(:call, post_out_of_sync_deploys_service_mock) do
      Rake.application.invoke_task "post_out_of_sync_deploys"

      assert_mock post_out_of_sync_deploys_service_mock
    end
  end
end
