class Application < ApplicationRecord
  extend FriendlyId

  friendly_id :fallback_shortname, use: :slugged, slug_column: :shortname

  validates_presence_of :name, message: "is required"
  validates_presence_of :repo, message: "is required"
  validates_presence_of :domain, message: "is required"

  validates :name, :repo, :domain, :status_notes, :shortname, length: { maximum: 255 }

  validates_format_of :repo, with: /\A[^\s\/]+\/[^\s\/]+\Z/i

  validates_uniqueness_of :name, :repo

  has_many :deployments, dependent: :destroy

  default_scope { order("name ASC") }

  def latest_deploy_to_each_environment
    return @latest_deploy_to_each_environment unless @latest_deploy_to_each_environment.nil?

    environments = deployments.select("DISTINCT environment").map(&:environment)
    @latest_deploy_to_each_environment = environments.each_with_object({}) do |environment, hash|
      hash[environment] = deployments.last_deploy_to(environment)
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
    self.repo.split("/")[-1] unless self.repo.nil?
  end

  def repo_url
    "https://#{domain}/#{repo}"
  end

  def repo_compare_url(from, to)
    "https://#{domain}/#{repo}/compare/#{from}...#{to}"
  end

  def repo_tag_url(tag)
    "https://#{domain}/#{repo}/releases/tag/#{tag}"
  end

  def production_and_staging_environments
    if self.on_aws?
      %w[production-aws staging-aws]
    else
      %w[production staging]
    end
  end
end
