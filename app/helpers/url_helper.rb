module UrlHelper
  def github_repo_url(app)
    Repo.url(app_name: app.name).nil? ? "https://github.com/alphagov/#{app.name.parameterize}" : Repo.url(app_name: app.name)
  end

  def github_dependency_link_to(app, text)
    link_to(text, "#{github_repo_url(app)}/pulls?q=is%3Apr+state%3Aopen+label%3Adependencies", target: "_blank", rel: "noopener", class: "govuk-link")
  end

  def github_tag_link_to(app, git_ref)
    link_to(git_ref.truncate(15), "#{github_repo_url(app)}/tree/#{git_ref}", target: "_blank", rel: "noopener", class: "govuk-link")
  end

  def github_compare_to_default(app, deploy)
    "#{github_repo_url(app)}/compare/#{deploy.version}...#{app.default_branch}"
  end

  def argo_app_link_to(app, environment, image_tag)
    link_to(image_tag, "https://argo.eks.#{environment}.govuk.digital/applications/#{app.downcase}", target: "_blank", rel: "noopener", class: "govuk-link")
  end
end
