class DirectSaleMailer < ApplicationMailer
  default from: email_address_with_name('tickets@londondecom.org', 'Decom Ticketing Team')

  def given_direct_sale
    @user = params[:user]
    mail(
      to: @user.email,
      subject: "You've been given a direct sale ticket!"
    )
  end
end
