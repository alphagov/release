class Application < ActiveRecord::Base
  attr_accessible :name, :repo, :shortname, :status_notes, :domain

  validates_presence_of :name, message: 'is required'
  validates_presence_of :repo, message: 'is required'
  validates_presence_of :domain, message: 'is required'

  validates_format_of :repo, with: /\A[^\s\/]+\/[^\s\/]+\Z/i

  validates_uniqueness_of :name, :repo

  has_many :tasks, dependent: :destroy
  has_many :releases, through: :tasks
  has_many :deployments

  default_scope order("name ASC")

  def latest_deploy_to_each_environment
    environments = deployments.select('DISTINCT environment').map(&:environment)
    environments.each_with_object({}) do |environment, hash|
      hash[environment] = deployments.last_deploy_to(environment)
    end
  end

  def latest_deploy_to(*environments)
    latest_deploy_to_each_environment.select { |env, deploy| environments.include?(env) }
  end

  def staging_and_production_in_sync?
    staging = latest_deploy_to_each_environment["staging"]
    production = latest_deploy_to_each_environment["production"]
    staging_version = staging.nil? ? nil : staging.version
    production_version = production.nil? ? nil : production.version
    staging_version == production_version
  end

  def shortname
    sn = self.read_attribute(:shortname)
    if sn.blank?
      self.fallback_shortname
    else
      sn
    end
  end

  def fallback_shortname
    self.repo.split('/')[-1] unless self.repo.nil?
  end

  def repo_url
    "https://#{domain}/#{repo}"
  end
end
