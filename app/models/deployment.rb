class Deployment < ActiveRecord::Base
  belongs_to :application

  attr_accessible :version, :environment, :application

  validates_presence_of :version, :environment, :application_id

  def self.environments
    Deployment.select('DISTINCT environment').map(&:environment)
  end

  def self.last_deploy_to(environment)
    where(environment: environment)
      .order("created_at DESC")
      .first
  end
end