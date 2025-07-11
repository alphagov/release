require "test_helper"

class K8sHelperTest < ActionView::TestCase
  context "k8s_data" do
    setup do
      filepath = Rails.root.join("test/fixtures/k8s/running.json")
      mock_resp = JSON.parse(File.read(filepath))
      K8sHelper.stubs(:pods_by_status).returns(mock_resp)
    end

    should "can parse response from kubernetes API" do
      assert_equal "{\"app_instance\":\"app1\",\"image\":\"v490\",\"created_at\":\"2025-05-14T08:52:29Z\"}", K8sHelper.k8s_data("test", "app1").to_json
    end
  end

  context "k8s_data empty" do
    setup do
      K8sHelper.stubs(:pods_by_status).returns([])
    end

    should "can parse empty response from kubernetes API" do
      assert_equal "{\"app_instance\":\"\",\"image\":\"None\",\"created_at\":\"\"}", K8sHelper.k8s_data("test", "app1").to_json
    end
  end

  LICENSIFY_APPS = %w[licensify-backend licensify-feed licensify-frontend].freeze

  context "namespace" do
    LICENSIFY_APPS.each do |app_name|
      should "returns licensify namespace if #{app_name}" do
        assert_equal "licensify", K8sHelper.namespace(app_name)
      end
    end

    should "returns apps namespace if not licensify" do
      assert_equal "apps", K8sHelper.namespace("app1")
    end
  end

  context "repo_name" do
    LICENSIFY_APPS.each do |app_name|
      should "returns licensify repo name for #{app_name}" do
        assert_equal "licensify", K8sHelper.repo_name(app_name)
      end
    end

    should "returns test-app if not licensify app name" do
      assert_equal "test-app", K8sHelper.repo_name("test-app")
    end

    should "returns email-alert-service if email-alert-service app name" do
      assert_equal "email-alert-service", K8sHelper.repo_name("email-alert-service")
    end
  end

  context "component" do
    should "returns licensify-admin for licensify-backend" do
      assert_equal "licensify-admin", K8sHelper.component("licensify-backend")
    end

    (LICENSIFY_APPS.last 2).each do |app_name|
      should "returns licensify #{app_name} if not licensify-backend" do
        assert_equal app_name, K8sHelper.component(app_name)
      end
    end

    should "returns worker if email-alert-service app name" do
      assert_equal "worker", K8sHelper.component("email-alert-service")
    end

    should "returns app if not licensify app name" do
      assert_equal "app", K8sHelper.component("test-app")
    end
  end
end
