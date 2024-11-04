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
    deleted_records = Rails.cache.delete_multi(
      %W[eventbrite:event:#{eventbrite_id}:discounts:#{code} eventbrite:event:#{eventbrite_id}:ticketclasses]
    )
    return unless deleted_records != 2

    Rollbar.warn(
      'Tried to clear discounts and ticket classes, had an issue doing so',
      records_cleared: "#{deleted_records} of an expected 2",
      current_user: current_user.id,
      current_user_membership_number: current_user.membership_number,
      provided_code: params[:code]
    )
  end
end
