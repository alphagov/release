module BreadcrumbHelper
  def root_crumb
    {
      title: "Applications",
      url: applications_path,
    }
  end

  def application_node_crumb(application:)
    {
      title: application.name,
      url: (application_path application),
    }
  end
end
