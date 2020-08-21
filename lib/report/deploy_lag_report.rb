class Report
  class DeployLagReport
    def call
      Application.all.flat_map { |app| deploy_sequences_for(app) }.compact
    end

  private

    def deploy_sequences_for(app)
      deploys = Deployment.where("created_at > ?", 1.year.ago).where(application: app)

      integration_deploys = deploys
        .where("environment LIKE 'integration%'")
        .select { |dep| dep.version =~ /release_/ }

      production_deploys = deploys
        .where("environment LIKE 'production%'")
        .select { |dep| dep.version =~ /release_/ }

      production_by_version = production_deploys.group_by { |dep| release_number_for(dep) }

      integration_deploys.map do |dep|
        prod_deploy = production_deploy_for(dep, production_by_version)
        next unless prod_deploy

        { app: app, deploy: dep, prod_deploy: prod_deploy }
      end
    end

    def production_deploy_for(deploy, by_version)
      version_no = release_number_for(deploy)
      prod_deploy = nil

      while prod_deploy.nil?
        return nil if version_no > (by_version.keys.max || 0)

        prod_deploys = by_version[version_no]
        version_no += 1
        next if prod_deploys.nil?

        prod_deploy = prod_deploys.first
      end

      prod_deploy
    end

    def release_number_for(deploy)
      deploy.version.split("_")[1].to_i
    end
  end
end
