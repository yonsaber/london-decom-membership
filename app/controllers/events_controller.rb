class EventsController < ApplicationController
  def clear_discount_from_cache
    if current_user.membership_code == params[:code]
      Rails.cache.delete("eventbrite:event:#{params[:eventbrite_id]}:discounts:#{params[:code]}")
    else
      head :bad_request
    end
  end
end
