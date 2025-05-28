require "base64"
require "aws-sdk-sts"
require "aws-sdk-eks"
require "aws-sdk-core"
require "k8s-ruby"

class ClusterState
  ROLES_TO_ASSUME = {
    "integration" => "arn:aws:iam::210287912431:role/release-assumed",
    "staging" => "arn:aws:iam::696911096973:role/release-assumed",
    "production" => "arn:aws:iam::172025368201:role/release-assumed",
  }.freeze
  CLUSTER_NAME = "govuk".freeze

  def generate_eks_token(credentials)
    signer = Aws::Sigv4::Signer.new(
      service: "sts",
      region: "eu-west-1",
      credentials_provider: credentials,
    )

    url = signer.presign_url(
      http_method: "GET",
      url: "https://sts.eu-west-1.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15",
      headers: { "x-k8s-aws-id" => CLUSTER_NAME },
    )

    "k8s-aws-v1.#{Base64.strict_encode64(url).gsub('=', '')}"
  end

  def self.create_client(environment)
    sts = Aws::STS::Client.new

    assumed_role = sts.assume_role({
      role_arn: ROLES_TO_ASSUME[environment],
      role_session_name: "govuk-release-role",
    })

    c = assumed_role.credentials

    assumed_creds = Aws::Credentials.new(
      c.access_key_id,
      c.secret_access_key,
      c.session_token,
    )

    eks_token = generate_eks_token assumed_role

    eks = Aws::EKS::Client.new(credentials: assumed_creds)

    cluster = eks.describe_cluster(name: CLUSTER_NAME).cluster

    k8s_config = K8s::Config.build(
      server: cluster.endpoint,
      ca: cluster.certificate_authority.data,
      cluster_name: CLUSTER_NAME,
      auth_token: eks_token,
    )

    K8s::Client.config(k8s_config)
  end

  def self.get_deploy(repo_name:)
    k8s = create_client(environment)

    deploys = k8s.api("v1").resource("deploy", namespace: "apps")
    k8s.api("v1").resource("deployments", namespace: "apps").list
    k8s.api("apps/v1/deployments").resource("signon").list
  end

  def self.get_pods_by_status(environment:, repo_name:, status:)
    Rails.logger.debug "Debug cluster_state: #{environment}, #{repo_name}, #{status}"
    ## just for demo purposes until the assume role permissions is fixed
    if repo_name == "Asset Manager"
      require "json"
      pods = JSON.parse(File.read('app/models/running.json'))
    else
        k8s = create_client(environment)
      pods = k8s.api("v1").resource("pods", namespace: "apps").list(labelSelector: { "app.kubernetes.io/instance" => repo_name }, fieldSelector: { "status.phase": status })
    end

    res = []
    pods.each do |pod|
      images = []
      pod["spec"]["containers"].each { |c| images.append({ "image" => c["image"] }) }
      creationTimestamp = pod["metadata"]["creationTimestamp"]
      res.append({
        "name" => pod["metadata"]["name"],
        "images" => images,
        "createdAt" => creationTimestamp,
      })
    end
    res
  end

  def self.get_running_pods(environment:, repo_name:)
    get_pods_by_status(environment: environment, repo_name: repo_name, status: "Running")
  end

  def self.get_image_tag(repo_name:, environment: "integration")
    pods = get_running_pods(repo_name: repo_name, environment: environment)
    {
      "image" => pods[0]["images"][0]["image"].split(":")[-1],
      "created_at" => pods[0]["createdAt"],
    }
  end

  def get_succeeded_cronjobs(repo_name:)
    get_pods_by_status(repo_name: repo_name, status: "Succeeded")
  end
end
