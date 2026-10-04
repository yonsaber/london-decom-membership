Rollbar.configure do |config|
  # Without configuration, Rollbar is enabled in all environments.
  # To disable in specific environments, set config.enabled=false.
  config.access_token = ENV.fetch('ROLLBAR_ACCESS_TOKEN', nil)

  # Here we'll disable in 'test':
  config.enabled = false if Rails.env.test?

  # Don't log lower than debug
  config.logger_level = 'info' if Rails.env.production?

  # Modification for fly.io (note should be changed in the future), currently there is an issue with rollbar detecting
  # the correct IP address in the X-FORWARDED-FOR header which does fail for IPv6 but shouldn't for IPv4, however it
  # doesn't correctly detect between the Fly proxy IP address and the actual client IP address
  config.user_ip_rack_env_key = 'FLY_CLIENT_IP'

  # Additionally, you may specify the following:
  # config.person_username_method = "username"
  config.person_email_method = 'email'

  config.environment = ENV['ROLLBAR_ENV'].presence || Rails.env
end
