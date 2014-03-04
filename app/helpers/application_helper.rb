module ApplicationHelper
  def nav_link(text, link)
    recognized = Rails.application.routes.recognize_path(link)
    if recognized[:controller] == params[:controller] && recognized[:action] == params[:action]
      content_tag(:li, :class => "active") do
        link_to(text, link)
      end
    else
      content_tag(:li) do
        link_to(text, link)
      end
    end
  end

  def human_datetime(date)
    if date
      if date.today?
        date.strftime("%-l:%M%P today")
      elsif (11.months.ago < date)
        date.strftime("%-l:%M%P on %-e %b")
      else
        date.strftime("%-l%P on %-e %b %Y")
      end
    else
      ""
    end
  end

  def github_tag_link_to(app, git_ref)
    link_to(git_ref, "#{app.repo_url}/tree/#{git_ref}", target: "_blank")
  end

  def github_compare_to_master(application, deploy)
    "#{application.repo_url}/compare/#{deploy.version}...master"
  end

  def application_metadata(applications, environments)
    applications.map do |application|
      versions = environments.map { |env|
        env_deploy = application.deployments.last_deploy_to(env)
        {env => env_deploy.version} unless env_deploy.nil?
      }.reject!(&:nil?)

      {
        name: application.name,
        repo: application.repo,
        domain: application.domain,
        staging_and_production_in_sync: application.staging_and_production_in_sync?,
        deployed_versions: versions,
      }
    end
  end
end
