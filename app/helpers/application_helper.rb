module ApplicationHelper
  def title(text, params = {})
    render 'govuk_publishing_components/components/title', { title: text }.merge(params)
  end

  def h2(text, params = {})
    render 'govuk_publishing_components/components/heading', { text: text, heading_level: 2 }.merge(params)
  end

  def h3(text, params = {})
    render 'govuk_publishing_components/components/heading', { text: text, heading_level: 3 }.merge(params)
  end

  def environment_tag(environment_name)
    tag.strong environment_name, class: "govuk-tag govuk-tag--#{environment_name}"
  end

  def nav_link(text, link)
    recognized = Rails.application.routes.recognize_path(link)
    if recognized[:controller] == params[:controller] && recognized[:action] == params[:action]
      content_tag(:li, class: "active") do
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
      elsif yesterday.cover?(date)
        date.strftime("%-l:%M%P yesterday")
      elsif this_week.cover?(date)
        date.strftime("%-l:%M%P on %A")
      elsif 11.months.ago < date
        date.strftime("%-l:%M%P on %-e %b")
      else
        date.strftime("%-l%P on %-e %b %Y")
      end
    else
      ""
    end
  end

  def github_tag_link_to(app, git_ref)
    link_to(git_ref.truncate(15), "#{app.repo_url}/tree/#{git_ref}", target: "_blank")
  end

  def github_compare_to_master(application, deploy)
    "#{application.repo_url}/compare/#{deploy.version}...master"
  end

  def jenkins_deploy_url(application, release_tag, environment)
    job_name = "Deploy_App"
    job_name = "Deploy_Puppet" if application.shortname == "puppet"
    subdomain_prefix = "deploy.staging"
    subdomain_prefix = "deploy" if environment == "production"
    escaped_release_tag = CGI.escape(release_tag)
    "https://#{subdomain_prefix}.publishing.service.gov.uk/job/#{job_name}/parambuild?TARGET_APPLICATION=#{application.shortname}&TAG=#{escaped_release_tag}".html_safe
  end

private

  def yesterday
    (Time.zone.now - 1.day).all_day
  end

  def this_week
    Time.zone.now.all_week
  end
end
