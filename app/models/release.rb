class Release < ActiveRecord::Base
  attr_accessible :notes, :task_ids

  has_many :tasks
  has_many :applications, through: :tasks

  accepts_nested_attributes_for :tasks

  validate :validate_tasks

  private

  def validate_tasks
    errors.add(:tasks, "requires at least one task") if tasks.length < 1
  end
end
