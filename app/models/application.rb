class Application < ActiveRecord::Base
  attr_accessible :name, :repo

  validates_presence_of :name, :message => 'is required'
end
