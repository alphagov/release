require "test_helper"

class K8sHelperTest < ActionView::TestCase
  context "k8s_image_tag" do
    setup do
      filepath = Rails.root.join("test/fixtures/k8s/running.json")
      mock_resp = JSON.parse(File.read(filepath))
      K8sHelper.stubs(:pods_by_status).returns(mock_resp)
    end

    should "can parse response from kubernetes API" do
      assert_equal "{\"image\":\"v490\",\"created_at\":\"2025-05-14T08:52:29Z\"}", K8sHelper.k8s_image_tag("test", "app1").to_json
    end
  end

  context "k8s_image_tag empty" do
    setup do
      K8sHelper.stubs(:pods_by_status).returns([])
    end

    should "can parse empty response from kubernetes API" do
      assert_equal "{\"image\":\"None\",\"created_at\":\"\"}", K8sHelper.k8s_image_tag("test", "app1").to_json
    end
  end

  context "namespace" do
    should "returns licensify namespace if licensify" do
      assert_equal "licensify", K8sHelper.namespace("licensify")
    end

    should "returns apps namespace if not licensify" do
      assert_equal "apps", K8sHelper.namespace("app1")
    end
  end
end
