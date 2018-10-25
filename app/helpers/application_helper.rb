module ApplicationHelper
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
    link_to(git_ref.truncate(20), "#{app.repo_url}/tree/#{git_ref}", target: "_blank")
  end

  def github_compare_to_master(application, deploy)
    "#{application.repo_url}/compare/#{deploy.version}...master"
  end

  def jenkins_deploy_url(application, release_tag, environment)
    job_name = "Deploy_App"
    job_name = "Deploy_Puppet" if application.shortname == "puppet"

    if application.on_aws
      subdomain_prefix = "deploy.blue.#{environment}"
    else
      subdomain_prefix = "deploy.staging"
      subdomain_prefix = "deploy" if environment.include?("production")
    end

    escaped_release_tag = CGI.escape(release_tag)
    domain = if application.on_aws
               "govuk.digital"
             else
               "publishing.service.gov.uk"
             end

    "https://#{subdomain_prefix}.#{domain}/job/#{job_name}/parambuild?TARGET_APPLICATION=#{application.shortname}&TAG=#{escaped_release_tag}".html_safe
  end

private

  def yesterday
    (Time.zone.now - 1.day).all_day
  end

  def this_week
    Time.zone.now.all_week
  end
end
