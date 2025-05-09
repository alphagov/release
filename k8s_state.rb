require "base64"
require "aws-sdk-sts"
require "aws-sdk-eks"
require "aws-sdk-core"
require "k8s-ruby"

# ROLE_TO_ASSUME = "arn:aws:iam::210287912431:role/release-assumed"
ROLE_TO_ASSUME = "arn:aws:iam::210287912431:role/release-assumer"

def generate_eks_token(credentials)
  signer = Aws::Sigv4::Signer.new(
    service: "sts",
    region: "eu-west-1",
    credentials_provider: credentials,
  )

  url = signer.presign_url(
    http_method: "GET",
    url: "https://sts.eu-west-1.amazonaws.com/?Action=GetCallerIdentity&Version=2011-06-15",
    headers: { "x-k8s-aws-id" => "govuk" },
  )

  "k8s-aws-v1." + Base64.strict_encode64(url)
end

sts = Aws::STS::Client.new

assumed_role = sts.assume_role({
  role_arn: ROLE_TO_ASSUME,
  role_session_name: "test-role-release",
})

c = assumed_role.credentials

assumed_creds = Aws::Credentials.new(
  c.access_key_id,
  c.secret_access_key,
  c.session_token,
)

eks_token = generate_eks_token assumed_role

eks = Aws::EKS::Client.new(credentials: assumed_creds)

cluster = eks.describe_cluster(name: "govuk").cluster

k8s_config = K8s::Config.build(
  server: cluster.endpoint,
  ca: cluster.certificate_authority.data,
  cluster_name: "govuk",
  auth_token: eks_token,
)

k8s = K8s::Client.config(k8s_config)

print k8s.api("v1").resource("pods", namespace: "apps").list
