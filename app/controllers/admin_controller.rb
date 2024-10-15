class AdminController < ApplicationController
  before_action :authenticate_admin!
  before_action :fetch_active_event

  protected

  def authenticate_admin!
    return true if current_user&.admin?

    render plain: 'You are not permitted to view this'
    false
  end

  def fetch_active_event
    @event = Event.active(early_access: current_user&.early_access?)
  end
end
