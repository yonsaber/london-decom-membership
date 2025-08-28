class VolunteerRole < ApplicationRecord
  belongs_to :event
  has_many :volunteers, dependent: :destroy

  validates :name, presence: true
  validates :brief_description, presence: true
  validates :description, presence: true

  scope :available_for_user, lambda { |user|
    where.not(id: user.volunteers.pluck(:volunteer_role_id))
         .where(hidden: false)
  }

  def leads
    volunteers.where(lead: true)
  end

  def lead_emails
    leads.collect { |l| l.user.email }
  end

  # Checks if a role is below the 25% threshold (rounded up) of being able to support more people applying
  # @return [TrueClass, FalseClass]
  def below_threshold?
    ((available_slots.to_f / 100) * 25).ceil >= remaining_slots
  end

  # Checks if there are any available slots
  # @return [TrueClass, FalseClass]
  def any_available_slots?
    if available_slots.zero?
      true
    else
      !remaining_slots.zero?
    end
  end

  # Shows the number of remaining slots for the role, ignoring the leads in the counting
  # @return [Integer]
  def remaining_slots
    # Avoid showing negative numbers on the site because that is a bad look!
    slots_remain = available_slots - volunteers.where(lead: false).count
    if slots_remain.zero? || slots_remain.negative?
      0
    else
      slots_remain
    end
  end
end
