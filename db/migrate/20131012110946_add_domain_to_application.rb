class AddDomainToApplication < ActiveRecord::Migration
  def up
    add_column :applications, :domain, :string

    Application.all.each do |app|
      app.domain = if app.repo.start_with? "gds"
                     "github.gds"
                   else
                     "github.com"
                   end
      app.save!
    end
  end

  def down
    remove_column :applications, :domain
  end
end
