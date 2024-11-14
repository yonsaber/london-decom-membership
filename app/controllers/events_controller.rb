class EventsController < ApplicationController
  def clear_discount_from_cache
    if current_user.membership_number == params[:code]
      delete_records_in_cache(params[:eid], params[:code])
      head :ok
    else
      Rollbar.warn(
        'Attempted to clear cache value by user not matching member number',
        current_user: current_user.id,
        current_user_membership_number: current_user.membership_number,
        provided_code: params[:code]
      )
      head :bad_request
    end
  end

  private

  def delete_records_in_cache(eventbrite_id, code)
    discount_key = "eventbrite:event:#{eventbrite_id}:discounts:#{code}"
    ticket_classes_key = "eventbrite:event:#{eventbrite_id}:ticketclasses"

    if Rails.cache.exists?(discount_key)
      cleared_discount = Rails.cache.delete("eventbrite:event:#{eventbrite_id}:discounts:#{code}")
    end

    cleared_ticket_classes = Rails.cache.delete(ticket_classes_key) if Rails.cache.exists?(discount_key)

    return unless cleared_discount && cleared_ticket_classes

    Rollbar.warn(
      'Tried to clear discounts and ticket classes, had an issue doing so',
      cleared_ticket_classes:,
      cleared_discount:,
      current_user: current_user.id,
      current_user_membership_number: current_user.membership_number,
      provided_code: params[:code]
    )
  end
end
