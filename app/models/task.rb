class Task < ActiveRecord::Base
  attr_accessible :additional_support_required, :application_changes, :description,
                  :extended_support_required, :notes, :version

  belongs_to :application
  belongs_to :release

  validates_presence_of :version, :application

  default_scope order("created_at DESC")
end
