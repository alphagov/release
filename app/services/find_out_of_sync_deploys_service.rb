class FindOutOfSyncDeploysService
  class << self
    delegate :call, to: :new
  end

  def call
    return {} if out_of_sync_apps.empty?

    out_of_sync_apps_info.group_by { |app| app[:team] }
  end

private

  def out_of_sync_apps
    Application.where(archived: false).reject do |app|
      app.deployed_to_ec2? ||
        app.status == :all_environments_match
    end
  end

  def out_of_sync_apps_info
    out_of_sync_apps.map do |app|
      {
        name: app.name,
        shortname: app.shortname,
        repo: app.repo,
        status: app.status,
        team: find_team(app.name) || "#govuk-developers",
      }
    end
  end

  def find_team(app_name)
    Repo.all.find { |app| app["app_name"] == app_name.parameterize }&.dig("team")
  end
end
