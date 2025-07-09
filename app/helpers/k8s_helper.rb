module K8sHelper
  def self.k8s_apps
    @k8s_apps ||= YAML.safe_load(open("data/k8s_apps.yml"))
  end

  def self.namespace(repo_name)
    if K8sHelper.k8s_apps.include? repo_name
      namespace = K8sHelper.k8s_apps[repo_name]["namespace"]
    end
    namespace || "apps"
  end

  def self.repo_name(repo_name)
    if K8sHelper.k8s_apps.include? repo_name
      repo_name = K8sHelper.k8s_apps[repo_name]["repo_name"]
    end
    repo_name
  end

  def self.component(repo_name)
    if K8sHelper.k8s_apps.include? repo_name
      component = if K8sHelper.k8s_apps[repo_name].include? "component"
                    K8sHelper.k8s_apps[repo_name]["component"]
                  else
                    repo_name
                  end
    end
    component || "app"
  end

  def self.pods_by_status(environment:, repo_name:, status:)
    client = Services.k8s(environment: environment)
    client.get_pods(
      namespace: K8sHelper.namespace(repo_name),
      label_selector: "app.govuk/repository-name=#{K8sHelper.repo_name(repo_name)},app.kubernetes.io/component=#{K8sHelper.component(repo_name)}",
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
