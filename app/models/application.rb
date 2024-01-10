class Application < ApplicationRecord
  extend FriendlyId

  friendly_id :fallback_shortname, use: :slugged, slug_column: :shortname

  validates :name, presence: { message: "is required" }
  validates :repo, presence: { message: "is required" }

  validates :name, :repo, :status_notes, :shortname, length: { maximum: 255 }

  validates :repo, format: { with: /\A[^\s\/]+\/[^\s\/]+\Z/i }, allow_blank: true

  validates :name, uniqueness: { case_sensitive: true }

  validates :default_branch, presence: true

  enum default_branch: { master: "master", main: "main" }, _prefix: true

  has_many :deployments, dependent: :destroy

  default_scope { order("name ASC") }

  ENVIRONMENTS_ORDER = %w[integration staging production].freeze

  def latest_deploys_by_environment
    @latest_deploys_by_environment ||= (deployed_to_ec2? ? ENVIRONMENTS_ORDER : ENVIRONMENTS_ORDER.map { |env| "#{env} EKS" })
      .index_with { |environment| deployments.last_deploy_to(environment) }
      .compact
  end

  def in_sync?(environments)
    latest_deploys_by_environment
      .slice(*environments)
      .values
      .map(&:version)
      .uniq
      .length <= 1
  end

  def status
    envs = %w[production staging integration]
    envs = envs.map { |env| "#{env} EKS" } unless deployed_to_ec2?

    return :production_and_staging_not_in_sync unless in_sync?(envs.take(2))
    return :undeployed_changes_in_integration unless in_sync?(envs)

    :all_environments_match
  end

  def fallback_shortname
    repo.split("/")[-1] unless repo.nil?
  end

  def repo_url
    "https://github.com/#{repo}"
  end

  def repo_compare_url(from, to)
    "https://github.com/#{repo}/compare/#{from}...#{to}"
  end

  def self.ec2_deployed_apps
    @ec2_deployed_apps ||= YAML.safe_load_file("data/ec2_deployed_apps.yml")
  end

  def self.cd_statuses
    @cd_statuses ||= YAML.safe_load(open("data/continuously_deployed_apps.yml"))
  end

  def cd_enabled?
    key = shortname || fallback_shortname
    Application.cd_statuses.include? key
  end

  def deployed_to_ec2?
    key = shortname || fallback_shortname
    Application.ec2_deployed_apps.include? key
  end

  def dependency_pull_requests
    Services.github.search_issues("repo:#{repo} is:pr state:open label:dependencies")
  end

  def commits
    Services.github.commits(repo)
  end

  def latest_commit(application, commit_sha)
    Services.github.commit(application.repo, commit_sha)
  end

  def tag_names_by_commit
    tags = Services.github.tags(repo)

    tags.each_with_object({}) do |tag, hash|
      sha = tag[:commit][:sha]
      hash[sha] ||= []
      hash[sha] << tag[:name]
    end
  end

  def undeployed_commits
    production_deployment = deployments.last_deploy_to(live_environment)

    comparison = Services.github.compare(
      repo,
      production_deployment.version,
      default_branch,
    )
    # The `compare` API shows commits in forward chronological order
    comparison.commits.reverse + [comparison.base_commit]
  end

  def live_environment
    if deployed_to_ec2?
      "production"
    else
      "production EKS"
    end
  end

  def team_name
    Repo.find_by(app_name: name)&.dig("team") || "#govuk-developers"
  end
end
