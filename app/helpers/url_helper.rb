module UrlHelper
  def dashboard_url(application, environment)
    suffix = govuk_domain_suffix(environment, on_aws: application.on_aws?)
    "https://grafana.#{suffix}/dashboard/file/#{application.shortname}.json"
  end

  def smokey_url(application, environment)
    suffix = govuk_domain_suffix(environment, on_aws: application.on_aws?)
    "https://deploy.#{suffix}/job/Smokey"
  end
end
