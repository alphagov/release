class PopulateApplicationShortnames < ActiveRecord::Migration
  def up
    Application.find_each do |app|
      app.shortname = nil if app.shortname == ""
      app.save!
    end
  end
end
