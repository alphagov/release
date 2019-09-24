class AddDomainToApplication < ActiveRecord::Migration
  def up
    add_column :applications, :domain, :string

    Application.all.each do |app|
      if app.repo.start_with? "gds"
        app.domain = "github.gds"
      else
        app.domain = "github.com"
      end
      app.save!
    end
  end

  def down
    remove_column :applications, :domain
  end
end
