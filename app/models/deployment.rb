class Deployment < ActiveRecord::Base
  belongs_to :application

  attr_accessible :version, :environment, :application
end