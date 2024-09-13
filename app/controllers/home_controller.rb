class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index confirmation_notice]
  helper_method :resource_name, :resource, :devise_mapping, :resource_class

  def index
    if current_user
      @event = Event.active(early_access: current_user.early_access)
      @volunteer_roles = @event.volunteer_roles.available_for_user(current_user).all if @event && !@event.ended?
    else
      @user = User.new
      render :registration
    end
  end

  def resource_name
    :user
  end

  def resource
    @resource ||= User.new
  end

  def resource_class
    User
  end

  def devise_mapping
    @devise_mapping ||= Devise.mappings[:user]
  end

  def confirmation_notice; end
end
