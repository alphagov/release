class Release < ActiveRecord::Base
  attr_accessible :notes

  has_many :tasks

  validate :validate_tasks

  private

  def validate_tasks
    errors.add(:tasks, "requires at least one task") if tasks.length < 1
  end
end
