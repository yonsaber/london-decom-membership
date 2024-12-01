class DirectSaleMailer < ApplicationMailer
  def given_direct_sale(user)
    mail(
      to: user.email,
      from: 'tickets@londondecom.org',
      subject: "You've been given a direct sale ticket!"
    )
  end
end
