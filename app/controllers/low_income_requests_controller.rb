class LowIncomeRequestsController < ApplicationController
  def new
    # Returning existing during new so if the user goes directly to the link we don't have them submitting
    # a nth request to us and breaking the other functionality in this app
    @existing_request = current_user.low_income_request
    @low_income_request = LowIncomeRequest.new(user: current_user)
  end

  def create
    if current_user.low_income_request.present?
      active_request_time = current_user.low_income_request.created_at.strftime('%A %d %B %Y')
      flash[:alert] =
        "You already have a low income request submitted on #{active_request_time} please check back
         later to see if it's been approved!"
    else
      @low_income_request = LowIncomeRequest.new(low_income_request_params.merge(user: current_user))
      LowIncomeMailer.application_received(@low_income_request).deliver_now
      @low_income_request.save!
    end
    redirect_to root_path
  end

  private

  def low_income_request_params
    params.expect(low_income_request: [:request_reason])
  end
end
