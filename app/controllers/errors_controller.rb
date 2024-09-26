class ErrorsController < ApplicationController
  before_action :set_default_response_format

  def show
    respond_to do |format|
      format.html { render status_code.to_s, { status: status_code } }
    end
  rescue ActionController::UnknownFormat
    render status_code.to_s, { status: status_code }
  end

  protected

  def status_code
    params[:code] || 500
  end

  def set_default_response_format
    request.format = :html
  end
end
