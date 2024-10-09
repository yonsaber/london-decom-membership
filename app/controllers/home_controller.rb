class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[index confirmation_notice]

  def index
    if current_user
      @event = Event.active(early_access: current_user.early_access)
    else
      @user = User.new
      render :registration
    end
  end

  def confirmation_notice; end
end
