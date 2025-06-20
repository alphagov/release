require "base64"
require "aws-sdk-sts"
require "aws-sdk-eks"
require "kubeclient"

module Services
  def self.github
    credentials = defined?(GITHUB_CREDENTIALS) ? GITHUB_CREDENTIALS : {}
    @github ||= Octokit::Client.new(credentials)
  end

  AWS_REGION = "eu-west-1".freeze
  ASSUMED_ROLE_ARN = {
    "development" => "arn:aws:iam::210287912431:role/release-assumed",
    "integration" => "arn:aws:iam::210287912431:role/release-assumed",
    "staging" => "arn:aws:iam::696911096973:role/release-assumed",
    "production" => "arn:aws:iam::172025368201:role/release-assumed",
  }.freeze
  EKS_CLUSTER_NAME = "govuk".freeze

  def self.k8s(environment: "integration", version: "v1")
    credentials = Aws::AssumeRoleCredentials.new({
      client: Aws::STS::Client.new(region: AWS_REGION),
      role_arn: ASSUMED_ROLE_ARN[environment],
      role_session_name: "release-app",
    })

    eks = Aws::EKS::Client.new(credentials: credentials)

    cluster = eks.describe_cluster(name: EKS_CLUSTER_NAME).cluster

    auth_options = {
      bearer_token: Kubeclient::AmazonEksCredentials.token(credentials, EKS_CLUSTER_NAME),
    }

    cert_store = OpenSSL::X509::Store.new
    ca_cert_data = Base64.decode64(cluster.certificate_authority.data)
    cert_store.add_cert(OpenSSL::X509::Certificate.new(ca_cert_data))
    ssl_options = {
      cert_store: cert_store,
      verify_ssl: OpenSSL::SSL::VERIFY_PEER,
    }

    Kubeclient::Client.new(
      cluster.endpoint,
      version,
      auth_options: auth_options,
      ssl_options: ssl_options,
    )
  end
end
