namespace :whitehall_release_candidate do
  desc "Show the whitehall release candidate url"
  task :show => :environment do
    require 'release_candidate_announcer'
    whitehall_application = Application.find_by_name!("Whitehall")
    puts ReleaseCandidateAnnouncer.new(whitehall_application).release_url
  end

  desc "Announce the whitehall release candidate in campfire"
  task :announce => :environment do
    require 'release_candidate_announcer'
    whitehall_application = Application.find_by_name!("Whitehall")
    ReleaseCandidateAnnouncer.new(whitehall_application).announce!
  end
end