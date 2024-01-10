class FindOutOfSyncDeploysService
  class << self
    delegate :call, to: :new
  end

  def call
    return {} if Application.out_of_sync.empty?

    out_of_sync_apps_info.group_by { |app| app[:team] }
  end

private

  def out_of_sync_apps_info
    Application.out_of_sync.map do |app|
      {
        name: app.name,
        shortname: app.shortname,
        repo: app.repo,
        status: app.status,
        team: app.team_name,
      }
    end
  end
end
