module ClusterHelper
  def get_cluster_image_tag(environment, repo_name)
    ClusterState.get_image_tag(environment: environment, repo_name: repo_name)
  end
end
