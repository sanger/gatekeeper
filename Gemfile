# frozen_string_literal: true

# A sample Gemfile
# We use http rather than https due to difficulties navigating the proxy otherwise
source 'http://rubygems.org'

gem 'rails', '~>4.0.2'
gem 'puma'

gem 'sass-rails', '>= 3.2'
gem 'therubyracer'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'bootstrap-datepicker-rails'
gem 'hashie'
gem 'exception_notification'
gem 'sanger_barcode_format', github: 'sanger/sanger_barcode_format', branch: 'development'

gem 'sequencescape-client-api', require: 'sequencescape'
gem 'pmb-client', '0.1.0', github: 'sanger/pmb-client'

group :development do
  gem 'pry'
  gem 'yard', require: false
  gem 'rubocop', require: false
end

group :deployment do
  gem 'psd_logger', github: 'sanger/psd_logger'
end

group :test do
  gem 'minitest'
  gem 'mocha'
  gem 'timecop'
  gem 'poltergeist'
  gem 'launchy'
  gem 'capybara'
  gem 'minitest-rails-capybara'
end
