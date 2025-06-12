require "base64"
require "aws-sdk-sts"
require "aws-sdk-eks"
require "aws-sdk-core"
require "aws-sigv4"
require "kubeclient"

module Services

  class << self
    def github
      credentials = defined?(GITHUB_CREDENTIALS) ? GITHUB_CREDENTIALS : {}
      @github ||= Octokit::Client.new(credentials)
    end

    AWS_REGION = "eu-west-1".freeze # TODO probably not needed
    # https://github.com/alphagov/govuk-infrastructure/blob/main/terraform/deployments/release/assumed.tf
    ASSUMED_ROLE_ARN = {
      "development" => "arn:aws:iam::210287912431:role/release-assumed",
      "integration" => "arn:aws:iam::210287912431:role/release-assumed",
      "staging" => "arn:aws:iam::696911096973:role/release-assumed",
      "production" => "arn:aws:iam::172025368201:role/release-assumed",
    }.freeze
    EKS_CLUSTER_NAME = "govuk".freeze

    def generate_eks_token(credentials)
      signer = Aws::Sigv4::Signer.new(
        service: "sts",
        region: AWS_REGION,
        credentials_provider: credentials,
      )

      url = signer.presign_url(
        http_method: "GET",
        url: "https://sts.eu-west-1.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15",
        headers: { "x-k8s-aws-id" => CLUSTER_NAME },
      )

      "k8s-aws-v1.#{Base64.strict_encode64(url).gsub('=', '')}"
    end

    def k8s(environment: "integration", version: "v1")
      credentials = Aws::AssumeRoleCredentials.new({ 
        client: Aws::STS::Client.new(region: AWS_REGION), 
        role_arn: ASSUMED_ROLE_ARN[environment], 
        role_session_name: "release-app-test"
      })

      eks = Aws::EKS::Client.new(credentials: credentials)

      cluster = eks.describe_cluster(name: EKS_CLUSTER_NAME).cluster

      auth_options = {
        bearer_token: Kubeclient::AmazonEksCredentials.token(credentials, EKS_CLUSTER_NAME)
      }

      cert_store = OpenSSL::X509::Store.new
      ca_cert_data = Base64.decode64(cluster.certificate_authority.data)
      cert_store.add_cert(OpenSSL::X509::Certificate.new(ca_cert_data))
      ssl_options = {
        cert_store: cert_store,
        verify_ssl: OpenSSL::SSL::VERIFY_PEER
      }

      Kubeclient::Client.new(
        cluster.endpoint, 
        version,
        auth_options: auth_options,
        ssl_options: ssl_options 
      )
    end

    def get_pods_by_status(environment:, repo_name:, status:)
      client = k8s(environment: environment)
      client.get_pods(namespace: 'apps', label_selector: "app.kubernetes.io/name=#{repo_name}", field_selector: { "status.phase": status })
    end

    def get_running_pods(repo_name:, environment: "integration")
      res = []
      pods = get_pods_by_status(environment: environment, repo_name: repo_name, status: "Running")
      pods.each do |pod|
        images = []
        pod["spec"]["containers"].each { |c| images.append({ "image" => c["image"] }) }
        creation_timestamp = pod["metadata"]["creationTimestamp"]
        res.append({
          "name" => pod["metadata"]["name"],
          "images" => images,
          "createdAt" => creation_timestamp,
        })
      end
      res
    end

    def get_k8s_image_tag(environment, repo_name)
      pods = get_running_pods(repo_name: repo_name, environment: environment)
      if pods != []
        {
          "image" => pods[0]["images"][0]["image"].split(":")[-1],
          "created_at" => pods[0]["createdAt"],
        }
      else
        {
          "image" => "None",
          "created_at" => "",
        }
      end
    end
  end
end

# puts "======integration======"
# puts Services.get_running_pods(environment: "integration", repo_name: "signon")
# puts Services.get_k8s_image_tag("integration", "signon")

# # puts "======staging======"
# # puts Services.get_image_tag(repo_name: "asset-manager", environment: "staging")
