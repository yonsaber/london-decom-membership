class LeadsMailer < ApplicationMailer
  def new_volunteer(volunteer)
    @volunteer = volunteer
    mail(
      to: get_to_email_with_fallback(volunteer),
      from: 'volunteers@londondecom.org',
      subject: "New Decom volunteer for #{volunteer.volunteer_role.name}"
    )
  end

  def cancelled_volunteer(volunteer)
    @volunteer = volunteer
    mail(
      to: get_to_email_with_fallback(volunteer),
      from: 'volunteers@londondecom.org',
      subject: "Decom volunteer cancellation for #{volunteer.volunteer_role.name}"
    )
  end

  def new_lead(volunteer)
    @volunteer = volunteer
    mail(
      to: volunteer.user.email,
      from: 'volunteers@londondecom.org',
      subject: "You've been made a lead of #{@volunteer.volunteer_role.name} for London Decom"
    )
  end

  private

  # NOTE: This is a safety check if we don't have a lead for a role then we send the email to volunteers just
  #       so we don't get flooded with error logs about trying to send emails to no recipients.
  def get_to_email_with_fallback(volunteer)
    to_emails = volunteer.volunteer_role.lead_emails
    to_emails&.push('volunteers@londondecom.org') if to_emails.nil? || to_emails.empty?
    to_emails
  end
end
