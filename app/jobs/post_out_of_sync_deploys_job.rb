class PostOutOfSyncDeploysJob < ApplicationJob
  def perform
    Application.out_of_sync.group_by(&:team_name).each do |team_channel, apps|
      SlackPosterJob.perform_later(
        formatted_slack_message(apps),
        team_channel,
        { "icon_emoji" => ":badger:" },
      )
    end
  end

private

  def formatted_slack_message(apps)
    "Hello :paw_prints:, this is your regular badgering to deploy!\n\n#{app_list(apps)}"
  end

  def app_list(apps)
    apps.map { |app| app_info(app) }.join("\n")
  end

  def app_info(app)
    "- <#{Plek.external_url_for('release')}/applications/#{app.shortname}|#{app.name}> – #{app.status.to_s.humanize} (<https://github.com/#{app.repo}/actions/workflows/deploy.yml|Deploy GitHub action>)"
  end
end
