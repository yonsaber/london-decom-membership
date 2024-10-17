class VolunteerRole < ApplicationRecord
  belongs_to :event
  has_many :volunteers, dependent: :destroy

  validates :name, presence: true
  validates :brief_description, presence: true
  validates :description, presence: true

  scope :available_for_user, lambda { |user|
    where.not(id: user.volunteers.pluck(:volunteer_role_id))
         .order(priority: :desc)
         .where('hidden IS NOT true')
  }

  def leads
    volunteers.where(lead: true)
  end

  def lead_emails
    leads.collect { |l| l.user.email }
  end

  def below_threshold?
    ((available_slots.to_f / 100) * 25).ceil >= remaining_slots
  end

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
