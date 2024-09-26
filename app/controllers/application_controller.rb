class ApplicationController < ActionController::Base
  skip_forgery_protection

  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  def not_found
    render '/errors/404', status: :not_found, locals: { missing_record_params: params }
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: %i[
        name
        accept_principles
        marketing_opt_in
        accept_emails
        accept_no_ticket
        accept_code_of_conduct
        accept_health_and_safety
      ]
    )
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name])
  end
end
