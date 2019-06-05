module BreadcrumbHelper
  def root_crumb
    {
      title: "Applications",
      url: applications_path
    }
  end
end
