module UrlHelper
  def dashboard_url(application, environment)
    suffix = govuk_domain_suffix(environment, on_aws: application.on_aws?)
    "https://grafana.#{suffix}/dashboard/file/#{application.shortname}.json"
  end

  def smokey_url(application, environment)
    suffix = govuk_domain_suffix(environment, on_aws: application.on_aws?)
    "https://deploy.#{suffix}/job/Smokey"
  end

  def github_tag_link_to(app, git_ref)
    link_to(git_ref.truncate(15), "#{app.repo_url}/tree/#{git_ref}", target: "_blank", rel: "noopener", class: "govuk-link")
  end

  def github_compare_to_master(application, deploy)
    "#{application.repo_url}/compare/#{deploy.version}...master"
  end

  def govuk_domain_suffix(environment, on_aws:)
    return "blue.#{environment}.govuk.digital" if on_aws
    return "publishing.service.gov.uk" if environment == "production"

    "#{environment}.publishing.service.gov.uk"
  end

  def jenkins_deploy_app_url(application, release_tag, environment)
    suffix = govuk_domain_suffix(environment, on_aws: application.on_aws?)
    escaped_release_tag = CGI.escape(release_tag)
    "https://deploy.#{suffix}/job/Deploy_App/parambuild?TARGET_APPLICATION=#{application.shortname}&TAG=#{escaped_release_tag}".html_safe
  end

  def jenkins_deploy_puppet_url(release_tag, environment, aws:)
    suffix = govuk_domain_suffix(environment, on_aws: aws)
    escaped_release_tag = CGI.escape(release_tag)
    "https://deploy.#{suffix}/job/Deploy_Puppet/parambuild?TAG=#{escaped_release_tag}".html_safe
  end
end
