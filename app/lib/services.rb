require "aws-sdk-core"
require "aws-sigv4"
require "kubeclient"

module Services
  def self.github
    credentials = defined?(GITHUB_CREDENTIALS) ? GITHUB_CREDENTIALS : {}
    @github ||= Octokit::Client.new(credentials)
  end

    AWS_REGION = "eu-west-1".freeze # TODO probably not needed
    # https://github.com/alphagov/govuk-infrastructure/blob/main/terraform/deployments/release/assumed.tf
    ASSUMED_ROLE_ARN = {
      integration: "arn:aws:iam::210287912431:role/release-assumed",
      staging: "arn:aws:iam::696911096973:role/release-assumed",
      production: "arn:aws:iam::172025368201:role/release-assumed",
    }.freeze
    EKS_CLUSTER_NAME = "govuk".freeze

  def self.k8s
    credentials = Aws::AssumeRoleCredentials.new({ 
      client: Aws::STS::Client.new(region: AWS_REGION), 
      role_arn: ASSUMED_ROLE_ARN[:integration], 
      role_session_name: "release-app-test"
    })

    # aws eks describe-cluster --name govuk | jq -r .cluster.endpoint
    eks_cluster_https_endpoint = "https://40103E003763BB02EBDDD57BD166AC21.gr7.eu-west-1.eks.amazonaws.com"
    auth_options = {
      bearer_token: Kubeclient::AmazonEksCredentials.token(credentials, EKS_CLUSTER_NAME)
    }

    client = Kubeclient::Client.new(
      eks_cluster_https_endpoint, 'v1', auth_options: auth_options
    )
  end
end
