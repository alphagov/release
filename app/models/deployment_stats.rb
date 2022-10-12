class DeploymentStats
  attr_reader :initial_scope

  def initialize(initial_scope = Deployment)
    @initial_scope = initial_scope
  end

  def per_month
    production_deploys
      .where("deployments.created_at < ?", Time.zone.today.at_beginning_of_month)
      .group("DATE_FORMAT(deployments.created_at,'%Y-%m')")
      .count
  end

  def per_year
    production_deploys
      .group("YEAR(deployments.created_at)")
      .count
  end

private

  def production_deploys
    @production_deploys ||= initial_scope
      .where(environment: "production")
      .joins(:application)
      .order("deployments.created_at ASC")
  end
end
