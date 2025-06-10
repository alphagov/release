module K8sHelper
  def self.pods_by_status(environment:, repo_name:, status:)
    client = Services.k8s(environment: environment)
    client.get_pods(
      namespace: "apps",
      label_selector: "app.kubernetes.io/name=#{repo_name}",
      field_selector: { "status.phase": status },
    )
  end

  def self.running_pods(repo_name:, environment: "integration")
    pods = pods_by_status(environment: environment, repo_name: repo_name, status: "Running")
    pods.map do |pod|
      images = pod["spec"]["containers"].map { |c| { "image" => c["image"] } }
      {
        "name" => pod["metadata"]["name"],
        "images" => images,
        "created_at" => pod["metadata"]["creationTimestamp"],
      }
    end
  end

  def self.k8s_image_tag(environment, repo_name)
    pods = running_pods(repo_name: repo_name, environment: environment)
    if pods.empty?
      {
        "image" => "None",
        "created_at" => "",
      }
    else
      {
        "image" => pods.first["images"].first["image"].split(":").last,
        "created_at" => pods.first["created_at"],
      }
    end
  end
end
