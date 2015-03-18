class RemoveUnnecessaryShortnames < ActiveRecord::Migration
  class Application < ActiveRecord::Base; end

  def up
    app = Application.find_by(shortname: "tariff")
    app.shortname = nil
    app.save!
    app = Application.find_by(shortname: "tariff-api")
    app.shortname = nil
    app.save!
  end

  def down
  end
end
