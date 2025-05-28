# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).

example_note = "Here is a note that will hopefully demonstrate how somebody might use the notes field to write a long note."

applications = [
  { name: "Asset Manager" },
  { name: "Content store" },
  { name: "Feedback" },
  { name: "Frontend", status_notes: example_note },
  { name: "Licensify" },
  { name: "Places Manager" },
  { name: "Publisher" },
  { name: "Rummager" },
  { name: "Signon" },
  { name: "Smart answers", shortname: "smartanswers" },
  { name: "Static" },
  { name: "Support" },
  { name: "Whitehall" },
]

applications.each do |application_hash|
  next if Application.find_by(name: application_hash[:name]).present?

  Application.create!(application_hash)
end

# Create a dummy user
u = User.new
u.name = "Winston"
u.email = "winston@gov.uk"
u.permissions = %w[signin]
u.save!
