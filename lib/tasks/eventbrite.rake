desc 'Pings eventbrite to find out who has bought tickets and caches the eventbrite data'
task tickets_bought: :environment do
  event = Event.find_by(active: true)
  # NOTE: We only care about this in pre-release or active, everything else isn't important
  if !event.nil? && (event.prerelease? || event.active)
    Rollbar.info("Checking tickets for event '#{event.name}'")
    eventbrite = EventbriteEvent.new(event.eventbrite_token, event.eventbrite_id)
    discount_codes = eventbrite.fetch_all_discounts
    memberships_not_in_eventbrite = []
    low_income_memberships_not_in_eventbrite = []
    direct_sale_memberships_not_in_eventbrite = []
    User.find_each do |user|
      membership_number = find_user_by_discount_code(event, user, discount_codes)

      unless membership_number.nil?
        case user.ticket_type
        when :low_income
          low_income_memberships_not_in_eventbrite.push(user.membership_number)
        when :direct
          direct_sale_memberships_not_in_eventbrite.push(user.membership_number)
        else
          memberships_not_in_eventbrite.push(user.membership_number)
        end
      end
    end
    if memberships_not_in_eventbrite.nil?
      Rollbar.info("Rake task 'tickets_bought' completed")
    else
      Rollbar.info("Rake task 'tickets_bought' completed",
                   memberships_not_in_eventbrite: memberships_not_in_eventbrite.join(','),
                   low_income_memberships_not_in_eventbrite: low_income_memberships_not_in_eventbrite.join(','),
                   direct_sale_memberships_not_in_eventbrite: direct_sale_memberships_not_in_eventbrite.join(','))
    end
  else
    Rollbar.info('No active events, skipping update')
  end
rescue StandardError => e
  Rollbar.error(e)
end

desc 'returns emails of ticket purchasers who have not yet volunteered. Run rake tickets_bought first'
task attendees_who_have_not_volunteered: :environment do
  attendees_who_have_not_volunteered = User.where(ticket_bought: true)
                                           .includes(:volunteers)
                                           .where(volunteers: { user_id: nil })
  if attendees_who_have_not_volunteered.nil?
    Rollbar.info("Rake task 'attendees_who_have_not_volunteered' completed")
  else
    Rollbar.info("Rake task 'attendees_who_have_not_volunteered' completed",
                 non_volunteering_users: attendees_who_have_not_volunteered.pluck(:email).join(','))
  end
end

desc 'returns emails user who have low income but not used yet. Run rake tickets_bought first'
task unused_low_income: :environment do
  unused_low_income = User.where('ticket_bought IS NOT true')
                          .includes(:low_income_request)
                          .where(low_income_requests: { status: 'approved' })
  if unused_low_income.nil?
    Rollbar.info("Rake task 'unused_low_income' completed")
  else
    Rollbar.info("Rake task 'unused_low_income' completed",
                 unused_low_income_tickets: unused_low_income.pluck(:email).join(','))
  end
end

private

def find_user_by_discount_code(event, user, discount_codes)
  discount_code = discount_codes.find do |discount_code_json|
    discount_code_json['code'] == user.membership_number
  end
  if discount_code.present?
    Rails.cache.write(
      "eventbrite:event:#{event.eventbrite_id}:discounts:#{user.membership_number}",
      [discount_code],
      expires_in: 1.day
    )
    user.update(ticket_bought: discount_code['quantity_sold'].positive?)
    nil
  else
    user.membership_number
  end
end
