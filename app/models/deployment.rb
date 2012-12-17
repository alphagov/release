class Deployment < ActiveRecord::Base
  belongs_to :application

  attr_accessible :tag, :environment, :application
end