class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :trackable,
         :recoverable, :rememberable, :validatable, :confirmable

  attr_accessor :last_sign_in_ip, :current_sign_in_ip

  validates :name, presence: true
  validates :over_eighteen, acceptance: true
  validates :accept_principles, acceptance: true
  validates :accept_emails, acceptance: true
  validates :accept_no_ticket, acceptance: true
  validates :accept_code_of_conduct, acceptance: true
  validates :accept_health_and_safety, acceptance: true
  validates :membership_code, presence: true

  before_validation :set_membership_code, on: :create

  has_one :membership_code, dependent: :destroy
  has_many :volunteers, dependent: :destroy
  has_one :low_income_request, dependent: :destroy
  has_one :direct_sale_code, dependent: :destroy

  scope :confirmed, -> { where('confirmed_at IS NOT NULL') }
  scope :unconfirmed, -> { where('confirmed_at IS NULL') }

  before_destroy :delete_mailchimp_user

  def ticket_type
    if low_income_request && low_income_request.status == 'approved'
      :low_income
    elsif direct_sale_code.present?
      :direct
    else
      :general
    end
  end

  def membership_number
    case ticket_type
    when :low_income
      low_income_request.low_income_code.code
    when :direct
      direct_sale_code.code
    else
      membership_code.code
    end
  end

  def volunteers_for_event(event)
    volunteers.select { |volunteer| volunteer.volunteer_role.event == event }
  end

  def lead_for?(volunteer_role)
    volunteers.where(volunteer_role:, lead: true).present?
  end

  def email_hash
    Digest::MD5.hexdigest(email)
  end

  def delete_mailchimp_user
    return if ENV['MAILCHIMP_TOKEN'].blank?

    # NOTE: This is only ARCHIVING the user not fully deleting them, we need a
    #       toggle for doing a GDPR delete, but that's a future change
    gibbon.lists(list_id).members(email_hash).delete
  rescue Gibbon::MailChimpError => e
    # NOTE: the reason for this is even if we check if the user exists, we'd get
    #       a 404 response from MailChimp and whilst we shouldn't exclude errors
    #       there is little benefit to reporting this error
    Rollbar.error(e) if e.status_code != 404
  end

  def update_mailchimp
    return if ENV['MAILCHIMP_TOKEN'].blank?

    mailchimp_upsert('subscribed')
    gibbon.lists(list_id).members(email_hash).tags.create(
      body: {
        tags: [
          { name: 'member', status: 'active' },
          { name: 'member-marketing', status: (marketing_opt_in ? 'active' : 'inactive') }
        ]
      }
    )
  rescue Gibbon::MailChimpError => e
    Rollbar.error(e)

    begin
      # NOTE: If a member is in compliance state, we are able to resubscribe them by setting their state to pending
      #       this should resend the confirmation email to them so they are no longer in a compliance state
      # References for this change:
      # * https://www.drupal.org/project/mailchimp/issues/2188819
      # * https://stackoverflow.com/questions/42159327/resubscribe-a-user-to-a-mailchimp-list-after-unsubscribe
      mailchimp_upsert('pending') if e.status_code == 400 && !e.title.downcase.index('member in compliance state').nil?
    rescue Gibbon::MailChimpError => e
      Rollbar.error(e)
    end
  end

  private

  def set_membership_code
    self.membership_code = MembershipCode.available.first || MembershipCode.create!
  end

  def gibbon
    @gibbon ||= Gibbon::Request.new(api_key: ENV.fetch('MAILCHIMP_TOKEN', nil))
  end

  def list_id
    @list_id ||= gibbon.lists.retrieve.body['lists'].first['id']
  end

  def mailchimp_upsert(status)
    gibbon.lists(list_id).members(email_hash).upsert(
      body: {
        email_address: email,
        status:,
        merge_fields: { NAME: name }
      }
    )
  end
end
