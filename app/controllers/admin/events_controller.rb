class Admin::EventsController < AdminController
  def index
    @events = Event.all
  end

  def show
    @event = Event.find(params[:id])

    @has_event_cache_entry = Rails.cache.exist?("eventbrite:event:#{@event.eventbrite_id}")
    @has_ticket_class_cache_entry = Rails.cache.exist?("eventbrite:event:#{@event.eventbrite_id}:ticketclasses")
  end

  def new
    @event = Event.new
  end

  def create
    @event = Event.new(event_params)
    if @event.save
      redirect_to admin_events_path(@event)
    else
      render action: :new
    end
  end

  def edit
    @event = Event.find(params[:id])
  end

  def update
    @event = Event.find(params[:id])

    if @event.update(event_params)
      redirect_to admin_event_path(@event)
    else
      render action: :edit
    end
  end

  def clear_event_from_cache
    @event = Event.find(params[:event_id])
    return if @event.nil?

    deleted = Rails.cache.delete("eventbrite:event:#{@event.eventbrite_id}")
    if deleted
      flash[:notice] = 'Successfully cleared event data from cache'
    else
      flash[:alert] = 'There was an issue clearing the event from cache, please contact the members team'
    end

    redirect_to admin_event_path(@event)
  end

  def clear_ticket_classes_from_cache
    @event = Event.find(params[:event_id])
    return if @event.nil?

    deleted = Rails.cache.delete("eventbrite:event:#{@event.eventbrite_id}:ticketclasses")
    if deleted
      flash[:notice] = 'Successfully cleared ticket classes data from cache'
    else
      flash[:alert] = 'There was an issue clearing the ticket classes from cache, please contact the members team'
    end

    redirect_to admin_event_path(@event)
  end

  private

  def event_params
    params.require(:event).permit(
      :name, :active,
      :ticket_sale_start_date, :theme, :theme_details, :theme_image_url,
      :location, :maps_location_url, :event_timings, :further_information,
      :ticket_price_info, :ticket_information, :event_date, :event_mode,
      :low_income_requests_start, :low_income_requests_end
    )
  end
end
