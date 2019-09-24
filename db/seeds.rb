# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

example_note = "Here is a note that will hopefully demonstrate how somebody might use the notes field to write a long note."

applications = [
  { name: "Calendars",                              repo: "alphagov/calendars" },
  { name: "Content store",                          repo: "alphagov/content-store" },
  { name: "Feedback",                               repo: "alphagov/feedback" },
  { name: "Frontend",                               repo: "alphagov/frontend",                              status_notes: example_note },
  { name: "Imminence",                              repo: "alphagov/imminence" },
  { name: "Licence finder",                         repo: "alphagov/licence-finder",                        shortname: "licencefinder" },
  { name: "Licensify",                              repo: "alphagov/licensify" },
  { name: "Publisher",                              repo: "alphagov/publisher" },
  { name: "Puppet",                                 repo: "gds/puppet",                                     domain: "github.gds" },
  { name: "Rummager",                               repo: "alphagov/rummager" },
  { name: "Signon",                                 repo: "alphagov/signon" },
  { name: "Smart answers",                          repo: "alphagov/smart-answers",                         shortname: "smartanswers" },
  { name: "Static",                                 repo: "alphagov/static" },
  { name: "Support",                                repo: "alphagov/support" },
  { name: "Whitehall",                              repo: "alphagov/whitehall" },
  { name: "Data insight non-govuk reach collector", repo: "alphagov/datainsight-nongovuk-reach-collector",  archived: true },
]

applications.each do |application_hash|
  begin
    app_defaults = { domain: "github.com" }
    Application.create!(app_defaults.merge(application_hash))
  rescue ActiveRecord::RecordInvalid => e
    puts "Skipping #{application_hash[:name]}"
  end
end

# Create a dummy user
u = User.new
u.name = "Winston"
u.email = "winston@gov.uk"
u.permissions = ["signin"]
u.save!
