class Deployment < ActiveRecord::Base
  after_create :record_to_statsd
  belongs_to :application

  attr_accessible :version, :environment, :application, :application_id, :created_at

  validates_presence_of :version, :environment, :application_id

  def self.environments
    Deployment.select('DISTINCT environment').map(&:environment)
  end

  def self.last_deploy_to(environment)
    where(environment: environment)
      .order("created_at DESC")
      .first
  end

  def previous_deployment
    @previous_deployment ||= Deployment
      .where(application_id: self.application_id, environment: self.environment)
      .order("created_at DESC")
      .offset(1)
      .first
  end

  def recent?
    created_at > 2.hours.ago
  end

  private

    # Record the deployment to statsd and thence to graphite
    def record_to_statsd
      # Only record production deployments in production graphite
      if self.environment == "production"
        key = "deploys.#{self.application.shortname}"
        STATSD.increment(key)
      end
    end
end
