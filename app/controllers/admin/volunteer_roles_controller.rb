class Admin::VolunteerRolesController < AdminController
  before_action :find_event

  def index
    @volunteer_roles = @event.volunteer_roles.order(priority: :desc)
  end

  def new
    @volunteer_role = @event.volunteer_roles.new
  end

  def edit
    @volunteer_role = @event.volunteer_roles.find(params.expect(:id))
  end

  def create
    @volunteer_role = @event.volunteer_roles.new(volunteer_role_params)
    if @volunteer_role.save
      redirect_to admin_event_volunteer_roles_path(@event)
    else
      render action: :new
    end
  end

  def update
    @volunteer_role = @event.volunteer_roles.find(params.expect(:id))
    if @volunteer_role.update(volunteer_role_params)
      redirect_to admin_event_volunteer_roles_path(@event)
    else
      render action: :edit
    end
  end

  def destroy
    @volunteer_role = @event.volunteer_roles.find(params.expect(:id))
    @volunteer_role.destroy!
    redirect_to admin_event_volunteer_roles_path(@event)
  end

  private

  def volunteer_role_params
    params
      .expect(volunteer_role: [:name, :description, :brief_description, :hidden, :priority, :available_slots])
  end

  def find_event
    @event = Event.find(params.expect(:event_id))
  end
end
