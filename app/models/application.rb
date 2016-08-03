class Application < ActiveRecord::Base
  extend FriendlyId

  friendly_id :fallback_shortname, use: :slugged, slug_column: :shortname

  validates_presence_of :name, message: 'is required'
  validates_presence_of :repo, message: 'is required'
  validates_presence_of :domain, message: 'is required'

  validates_format_of :repo, with: /\A[^\s\/]+\/[^\s\/]+\Z/i

  validates_uniqueness_of :name, :repo

  has_many :deployments

  default_scope { order("name ASC") }

  def latest_deploy_to_each_environment
    return @latest_deploy_to_each_environment unless @latest_deploy_to_each_environment.nil?
    environments = deployments.select('DISTINCT environment').map(&:environment)
    @latest_deploy_to_each_environment = environments.each_with_object({}) do |environment, hash|
      hash[environment] = deployments.last_deploy_to(environment)
    end
  end

  def latest_deploy_to(*environments)
    latest_deploy_to_each_environment.select { |env, deploy| environments.include?(env) }
  end

  def interesting_deployments
    deployments.recent.interesting
  end

  def staging_and_production_in_sync?
    return @staging_and_production_in_sync unless @staging_and_production_in_sync.nil?
    staging = latest_deploy_to_each_environment["staging"]
    production = latest_deploy_to_each_environment["production"]
    staging_version = staging.nil? ? nil : staging.version
    production_version = production.nil? ? nil : production.version
    @staging_and_production_in_sync = (staging_version == production_version)
  end

  def fallback_shortname
    self.repo.split('/')[-1] unless self.repo.nil?
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

  def on_github_enterprise?
    domain == "github.gds"
  end
end
