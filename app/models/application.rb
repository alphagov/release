class Application < ActiveRecord::Base
  attr_accessible :name, :repo

  validates_presence_of :name, message: 'is required'
  validates_presence_of :repo, message: 'is required'

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

  def staging_and_production_in_sync?
    staging = latest_deploy_to_each_environment["staging"]
    production = latest_deploy_to_each_environment["production"]
    staging_version = staging.nil? ? nil : staging.version
    production_version = production.nil? ? nil : production.version
    staging_version == production_version
  end

  def tags
    github_client.tags(repo, "")
  end

  def github_client
    @github_client ||= Github.create_from_config(Rails.root.join("config", "github-credentials.yml"))
  end
end
