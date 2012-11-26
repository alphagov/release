class Deploy < ActiveRecord::Base
  attr_accessible :additional_support_required, :application_changes, :description,
                  :extended_support_required, :notes, :release, :version

  belongs_to :application

  validates_uniqueness_of :release
  validates_presence_of :version, :application
end
