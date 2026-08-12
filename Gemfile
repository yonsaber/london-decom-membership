source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '3.3.5'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0'
# Use postgresql as the database for Active Record
gem 'pg', '>= 0.18', '< 2.0'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 8.0.2'
gem 'dartsass-sprockets'
gem 'terser'
gem 'coffee-rails', '~> 5.0'

# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem 'jbuilder', '>= 2.15.1'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', '~> 1.18', '>= 1.24.6', require: false

gem 'rubocop', '1.88.1'
gem 'rubocop-capybara', '>= 3.0'
gem 'rubocop-rspec', '>= 3.10.2'
gem 'rubocop-rspec_rails', '>= 2.32'
gem 'rubocop-rails', '>= 2.35.5'
gem 'rubocop-factory_bot', '>= 2.28'

# Error log handling
gem 'rollbar', '>= 3.8'
gem 'ostruct' # TODO: Remove this once rollbar releases it's next version

# Use Redis adapter
gem 'redis'
gem 'redis-actionpack'

# Flexible authentication solution for Rails with Warden [https://github.com/plataformatec/devise]
gem 'devise'
gem 'devise-i18n'

gem 'bootstrap', '>= 5.3.8'
gem 'jquery-rails'
gem 'bootstrap_form'
gem 'select2-rails'

gem 'eventbrite_sdk'
gem 'http'
gem 'gibbon'

gem 'kaminari'
gem 'bootstrap4-kaminari-views'

# Use postmark gem to assist with emailing
gem 'postmark-rails'

gem 'recaptcha'

gem 'csv'

gem 'rack-attack'

gem 'whenever', require: false

gem 'image_processing', '~> 1.2'

group :development, :test do
  gem 'byebug', platforms: %i[mri windows]
  gem 'rspec-rails'
  gem 'brakeman', require: false
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'climate_control'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console', '>= 4.3'
  gem 'listen', '>= 3.10'
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.1'
  gem 'httplog'
  gem 'faker'
  gem 'dockerfile-rails', '>= 1.6'
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara', '~> 3.40'
  gem 'capybara-email'
  gem 'webdrivers', '~> 5.3', '>= 5.3.1', require: false
  gem 'webmock'
end

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]
