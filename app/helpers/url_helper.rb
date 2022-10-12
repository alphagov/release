module UrlHelper
  def dashboard_url(application, environment)
    suffix = govuk_domain_suffix(environment)
    "https://grafana.#{suffix}/dashboard/file/#{application.shortname}.json"
  end

  def smokey_url(environment)
    suffix = govuk_domain_suffix(environment)
    "https://deploy.#{suffix}/job/Smokey"
  end

  def github_dependency_link_to(app, text)
    link_to(text, "#{app.repo_url}/pulls?q=is%3Apr+state%3Aopen+label%3Adependencies", target: "_blank", rel: "noopener", class: "govuk-link")
  end

  def github_tag_link_to(app, git_ref)
    link_to(git_ref.truncate(15), "#{app.repo_url}/tree/#{git_ref}", target: "_blank", rel: "noopener", class: "govuk-link")
  end

  def github_compare_to_default(application, deploy)
    "#{application.repo_url}/compare/#{deploy.version}...#{application.default_branch}"
  end

  def govuk_domain_suffix(environment)
    if environment == "integration"
      "integration.publishing.service.gov.uk"
    else
      "blue.#{environment}.govuk.digital"
    end
  end

  def jenkins_deploy_url(application, release_tag, environment)
    suffix = govuk_domain_suffix(environment)
    job_name = application.shortname == "puppet" ? "Deploy_Puppet" : "Deploy_App"
    escaped_release_tag = CGI.escape(release_tag)
    "https://deploy.#{suffix}/job/#{job_name}/parambuild?TARGET_APPLICATION=#{application.shortname}&TAG=#{escaped_release_tag}".html_safe
  end
end
