class VolunteersController < ApplicationController
  before_action :find_event
  before_action :find_volunteer_role
  before_action :authenticate_lead, except: %i[new create destroy]

  def index
    @volunteers = @volunteer_role.volunteers.order(:created_at)
    respond_to do |format|
      format.html
      format.csv { send_data @volunteers.to_csv, filename: "volunteers-#{@volunteer_role.name}-#{Date.today}.csv" }
    end
  end

  def new
    @volunteer = current_user.volunteers.build(volunteer_role: @volunteer_role)
  end

  def create
    if @event.tickets_sold_for_code(current_user.membership_number).zero? && !@volunteer_role.is_pre_event_role?
      flash[:alert] =
        "We are not currently taking applications for the #{@volunteer_role.name} role, please check back later!"
      redirect_to event_volunteering_index_path(@event)
    elsif !@volunteer_role.any_available_slots?
      flash[:alert] = "Unfortunately the last available slot for the #{@volunteer_role.name} role has been taken"
      redirect_to event_volunteering_index_path(@event)
    else
      try_volunteer_user
    end
  end

  def destroy
    @current_user_volunteer_role = current_user.volunteers.find_by(volunteer_role: @volunteer_role)
    if current_user.lead_for?(@volunteer_role)
      lead_deleting_volunteer
    # NOTE: Previously if we were an admin and went to delete a user in the volunteers list
    #       we'd run into an issue where it couldn't find that volunteer and fail to destroy them
    #       this ensures we don't run into that issue any more
    elsif current_user.admin && @current_user_volunteer_role&.user_id != current_user.id
      admin_deleting_volunteer
    else
      volunteer_cancelling
    end
  end

  def update
    @volunteer = @volunteer_role.volunteers.find(params[:id])
    @volunteer.update(state: params[:volunteer][:state])
    redirect_to event_volunteer_role_volunteers_path(@event, @volunteer_role)
  end

  private

  def try_volunteer_user
    @volunteer = current_user.volunteers.build(volunteer_params)
    if @volunteer.save
      LeadsMailer.new_volunteer(@volunteer).deliver_now
      redirect_to event_volunteering_index_path(@event)
    else
      render action: :new
    end
  end

  def lead_deleting_volunteer
    @volunteer = @volunteer_role.volunteers.find(params[:id])
    @volunteer.destroy
    flash[:notice] = "#{@volunteer.user.name} has been removed as a volunteer"

    if current_user.lead_for?(@volunteer_role)
      redirect_to event_volunteer_role_volunteers_path(@event, @volunteer_role)
    else
      redirect_to root_path
    end
  end

  def admin_deleting_volunteer
    @volunteer = @volunteer_role.volunteers.find(params[:id])
    @volunteer.destroy
    LeadsMailer.admin_cancelled_volunteer(@volunteer).deliver_now
    flash[:notice] = "#{@volunteer.user.name} has been removed as a volunteer for #{@volunteer_role.name}"
    redirect_to event_volunteer_role_volunteers_path(@event, @volunteer_role)
  end

  def volunteer_cancelling
    @current_user_volunteer_role.destroy
    LeadsMailer.cancelled_volunteer(@current_user_volunteer_role).deliver_now
    flash[:notice] = "You are no longer volunteering for #{@volunteer_role.name}"
    redirect_to event_volunteering_index_path(@event)
  end

  def find_event
    @event = Event.find(params[:event_id])
  end

  def find_volunteer_role
    @volunteer_role = @event.volunteer_roles.find(params[:volunteer_role_id])
  end

  def volunteer_params
    params.require(:volunteer).permit(
      :accept_code_of_conduct,
      :accept_health_and_safety,
      :additional_comments,
      :phone
    ).merge(volunteer_role: @volunteer_role)
  end

  def authenticate_lead
    return if current_user.admin? || Volunteer.find_by(user: current_user, volunteer_role: @volunteer_role, lead: true)

    flash[:alert] = 'You are not permitted to view that page'
    redirect_to root_path
  end
end
