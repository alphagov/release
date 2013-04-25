# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

applications = [
  { "name" => "Business support finder",                "repo"=>"alphagov/business-support-finder",               "shortname" => "businesssupportfinder"},
  { "name" => "Calendars",                              "repo"=>"alphagov/calendars"},
  { "name" => "GOV.UK content API",                     "repo"=>"alphagov/govuk_content_api",                     "shortname" => "contentapi"},
  { "name" => "Design principles",                      "repo"=>"alphagov/design-principles",                     "shortname" => "designprinciples"},
  { "name" => "Enterprise finance guarantee",           "repo"=>"alphagov/EFG",                                   "shortname" => "efg"},
  { "name" => "Feedback",                               "repo"=>"alphagov/feedback"},
  { "name" => "Frontend",                               "repo"=>"alphagov/frontend"},
  { "name" => "Imminence",                              "repo"=>"alphagov/imminence"},
  { "name" => "Licence finder",                         "repo"=>"alphagov/licence-finder",                        "shortname" => "licencefinder"},
  { "name" => "Licensify",                              "repo"=>"alphagov/licensify"},
  { "name" => "Migratorator",                           "repo"=>"alphagov/migratorator"},
  { "name" => "Need-o-tron",                            "repo"=>"alphagov/need-o-tron",                           "shortname" => "needotron"},
  { "name" => "Panopticon",                             "repo"=>"alphagov/panopticon"},
  { "name" => "Publisher",                              "repo"=>"alphagov/publisher"},
  { "name" => "Puppet",                                 "repo"=>"gds/puppet"},
  { "name" => "Recommended links",                      "repo"=>"alphagov/recommended-links"},
  { "name" => "Redirector",                             "repo"=>"alphagov/redirector"},
  { "name" => "Rummager",                               "repo"=>"alphagov/rummager"},
  { "name" => "Signon-o-tron 2",                        "repo"=>"alphagov/signonotron2",                          "shortname" => "signon"},
  { "name" => "Smart answers",                          "repo"=>"alphagov/smart-answers",                         "shortname" => "smartanswers"},
  { "name" => "Smokey",                                 "repo"=>"alphagov/smokey"},
  { "name" => "Static",                                 "repo"=>"alphagov/static"},
  { "name" => "Support",                                "repo"=>"alphagov/support"},
  { "name" => "Trade tariff backend",                   "repo"=>"alphagov/trade-tariff-backend",                  "shortname" => "tariff-api"},
  { "name" => "Trade tariff frontend",                  "repo"=>"alphagov/trade-tariff-frontend",                 "shortname" => "tariff"},
  { "name" => "Whitehall",                              "repo"=>"alphagov/whitehall"},
  { "name" => "Data insight frontend",                  "repo"=>"alphagov/datainsight-frontend"},
  { "name" => "Data insight Akamai scanner",            "repo"=>"alphagov/datainsight-akamai-scanner"},
  { "name" => "Data insight narrative collector",       "repo"=>"alphagov/datainsight-narrative-collector"},
  { "name" => "Data insight GA collector",              "repo"=>"alphagov/datainsight-ga-collector"},
  { "name" => "Data insight non-govuk reach collector", "repo"=>"alphagov/datainsight-nongovuk-reach-collector"},
  { "name" => "Data insight everything recorder",       "repo"=>"alphagov/datainsight-everything-recorder"},
  { "name" => "Data insight narrative recorder",        "repo"=>"alphagov/datainsight-narrative-recorder"},
  { "name" => "Data insight rodays activity recorder",  "repo"=>"alphagov/datainsight-todays-activity-recorder"},
  { "name" => "Data insight weekly reach recorder",     "repo"=>"alphagov/datainsight-weekly-reach-recorder"},
  { "name" => "Data insight format success recorder",   "repo"=>"alphagov/datainsight-format-success-recorder"}
]

applications.each do |application_hash|
  begin
    Application.create!(application_hash)
  rescue ActiveRecord::RecordInvalid => e
    puts "Skipping #{application_hash['name']}"
  end
end
