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

  def latest_deploy_to_each_environment
    return @latest_deploy_to_each_environment unless @latest_deploy_to_each_environment.nil?

    environments = deployments.select("DISTINCT environment").map(&:environment)
    @latest_deploy_to_each_environment = environments.index_with do |environment|
      deployments.last_deploy_to(environment)
    end
  end

  def latest_deploy_to(*environments)
    latest_deploy_to_each_environment.select { |env, _deploy| environments.include?(env) }
  end

  def in_sync?(environments)
    latest_deploy_to(*environments)
      .values
      .map(&:version)
      .uniq
      .length <= 1
  end

  def status
    return :production_and_staging_not_in_sync unless in_sync?(production_and_staging_environments)
    return :undeployed_changes_in_integration unless in_sync?(
      production_and_staging_environments + %w[integration],
    )

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

  def repo_tag_url(tag)
    "https://github.com/#{repo}/releases/tag/#{tag}"
  end

  def production_and_staging_environments
    if on_aws?
      %w[production-aws staging-aws]
    else
      %w[production staging]
    end
  end

  def self.cd_statuses
    @cd_statuses ||= YAML.safe_load(open("data/continuously_deployed_apps.yml"))
  end

  def cd_enabled?
    key = shortname || fallback_shortname
    Application.cd_statuses.include? key
  end
end
