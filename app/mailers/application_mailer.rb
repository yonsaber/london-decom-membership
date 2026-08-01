class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name('members@londondecom.org', 'Decom Members Team')
  layout 'mailer'
end
