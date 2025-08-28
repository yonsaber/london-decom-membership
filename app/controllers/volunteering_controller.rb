class VolunteeringController < ApplicationController
  before_action :find_event

  def index
    @volunteer_roles = @event.volunteer_roles.available_for_user(current_user)
                             .order(is_pre_event_role: :desc)
                             .order(priority: :desc)
                             .all
  end

  private

  def find_event
    @event = Event.find(params[:event_id])
  end
end
