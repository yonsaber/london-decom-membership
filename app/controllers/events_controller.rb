class EventsController < ApplicationController
  def clear_discount_from_cache
    if current_user.membership_number == params[:code]
      Rails.cache.delete("eventbrite:event:#{params[:eid]}:discounts:#{params[:code]}")
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
end
