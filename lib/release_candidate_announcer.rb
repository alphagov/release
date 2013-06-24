# This is designed to calculate a release candidate of a particular app
class ReleaseCandidateAnnouncer
  def initialize(application)
    @application = application
  end

  def announce!
    date = candidate_date.strftime("%A %d/%-m")
    speak "Release candidate for #{date}: #{release_url}"
  end

  def current_production_release
    @application.latest_deploy_to_each_environment["production"].version
  end

  def latest_successful_build
    release_sha = github.branch(@application.repo, 'release').commit.sha
    release_tag = github.tags(@application.repo).find {|t| t.commit.sha == release_sha }
    release_tag.name
  rescue Octokit::Error => e
    Rails.logger.error("Github error: #{e}\n#{e.response_body}")
    room.speak "Unable to announce release candidate because of an error connecting to github: #{e}"
    room.paste e + "\n" + e.response_body
  end

  def release_url
    "https://github.com/#{@application.repo}/compare/#{current_production_release}...#{latest_successful_build}"
  end

  def speak(message)
    Rails.logger.info "Campfire: #{message}"
    room.speak(message)
  end

  def candidate_date
    if Date.today.friday?
      Date.today + 3
    else
      Date.today + 1
    end
  end

private
  def github
    @github ||= Octokit::Client.new(GITHUB_CREDENTIALS)
  end

  def campfire
    @campfire ||= Tinder::Campfire.new(CAMPFIRE_CREDENTIALS[:subdomain],
      token: CAMPFIRE_CREDENTIALS[:api_key]
    )
  end

  def room
    @room ||= campfire.find_room_by_id(CAMPFIRE_CREDENTIALS[:room_id])
  end
end
