module ApplicationHelper
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

  def navigation_items
    return [] unless current_user

    items = []

    items << { text: "Applications", href: applications_path, active: is_current?(applications_path) }
    items << { text: "Deploys", href: activity_path, active: is_current?(activity_path) }
    items << { text: "Settings", href: site_path, active: is_current?(site_path) }
    items << { text: "Stats", href: stats_path, active: is_current?(stats_path) }

    items << { text: current_user.name, href: Plek.new.external_url_for("signon") }
    items << { text: "Sign out", href: gds_sign_out_path }

    items
  end

  def is_current?(link)
    recognized = Rails.application.routes.recognize_path(link)
    recognized[:controller] == params[:controller] &&
      recognized[:action] == params[:action]
  end

private

  def yesterday
    (Time.zone.now - 1.day).all_day
  end

  def this_week
    Time.zone.now.all_week
  end
end
