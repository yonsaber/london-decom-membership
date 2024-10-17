class EventbriteDiscountCodeNotFound < StandardError; end

class EventbriteEvent
  attr_accessor :eventbrite_token, :eventbrite_id

  def initialize(eventbrite_token, eventbrite_id)
    @eventbrite_token = eventbrite_token
    @eventbrite_id = eventbrite_id
    EventbriteSDK.token = eventbrite_token
  end

  def eventbrite_event
    @eventbrite_event ||= Rails.cache.fetch("eventbrite:event:#{eventbrite_id}", expires_in: 1.day) do
      EventbriteSDK::Event.retrieve(id: eventbrite_id)
    end
  end

  delegate :organization_id, to: :eventbrite_event

  # NOTE: only used by rake tasks
  def fetch_all_discounts
    discounts = []
    page = 1
    finished = false
    until finished
      response = HTTP.get(
        "https://www.eventbriteapi.com/v3/organizations/#{organization_id}/discounts/" \
        "?scope=event&event_id=#{eventbrite_id}&token=#{eventbrite_token}&page_size=200&page=#{page}"
      )
      if JSON.parse(response)['error'] == 'BAD_PAGE'
        finished = true
      else
        discounts << JSON.parse(response)['discounts']
        page += 1
      end
    end
    discounts.flatten
  end

  def discount_code(code)
    return @discount_code if @discount_code

    discounts = Rails.cache.fetch("eventbrite:event:#{eventbrite_id}:discounts:#{code}", expires_in: 30.minutes) do
      response = HTTP.get(
        "https://www.eventbriteapi.com/v3/organizations/#{organization_id}/discounts/" \
        "?scope=event&code=#{code}&event_id=#{eventbrite_id}&token=#{eventbrite_token}"
      )
      JSON.parse(response)['discounts']
    end

    raise EventbriteDiscountCodeNotFound, "Code #{code} does not exist in Eventbrite" if discounts.empty?

    @discount_code = discounts[0]
  end

  def available_tickets_for_code(code)
    discount_code(code)['quantity_available'] - tickets_sold_for_code(code)
  rescue EventbriteDiscountCodeNotFound
    0
  end

  # FIXME: Ensure that ticket_bought gets reset at some point (and existing accounts that HAVE the value set)
  #        get reset correctly, this is just a slightly hacky way for the cache to know that the user has been
  #        changed and we can now show them all the volunteering opportunities
  def tickets_sold_for_code(code)
    quantity_sold = discount_code(code)['quantity_sold']

    # TODO: Move this out of this logic as we are doing too much here, massive hack and SQL hog (even if caching)
    ticket_sold = quantity_sold.positive?
    if ticket_sold
      user = find_user_by_code(code)
      if user.nil?
        Rollbar.error("Unable to find user with membership_number #{code}!")
      elsif ticket_sold != user.ticket_bought
        user.update(ticket_bought: ticket_sold)
      end
    end

    quantity_sold
  rescue EventbriteDiscountCodeNotFound
    0
  end

  private

  def find_user_by_code(code)
    user = MembershipCode.find_by(code:)&.user
    user = LowIncomeCode.find_by(code:)&.low_income_request&.user if user.nil?
    user = DirectSaleCode.find_by(code:).user if user.nil?
    user
  end
end
