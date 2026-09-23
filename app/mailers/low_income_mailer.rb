class LowIncomeMailer < ApplicationMailer
  def application_received(low_income_request)
    @low_income_request = low_income_request
    mail(
      to: low_income_request.user.email,
      from: 'tickets@londondecom.org',
      subject: 'Low Income Request Received'
    )
  end

  def approved_request(low_income_request)
    @low_income_request = low_income_request
    mail(
      to: low_income_request.user.email,
      from: 'tickets@londondecom.org',
      subject: 'Low Income Request Approved'
    )
  end

  def rejected_request(low_income_request)
    @low_income_request = low_income_request
    mail(
      to: low_income_request.user.email,
      from: 'tickets@londondecom.org',
      subject: 'Low Income Request Rejected'
    )
  end
end
