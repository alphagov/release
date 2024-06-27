class RemoveGovukSliCollectorIntegrationDeploys < ActiveRecord::Migration[7.1]
  def up
    Application
      .find_by(shortname: "govuk-sli-collector")
      .deployments
      .where(environment: "integration")
      .destroy_all
  end
end
