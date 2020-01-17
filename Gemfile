# frozen_string_literal: true

# A sample Gemfile
# We use http rather than https due to difficulties navigating the proxy otherwise
source 'https://rubygems.org'

gem 'rails', '~>5.1.2'
gem 'puma'

gem 'sass-rails', '>= 3.2'
gem 'therubyracer'
gem 'uglifier', '>= 1.3.0'
gem 'jquery-rails'
gem 'bootstrap-sass'
gem 'bootstrap-datepicker-rails', '~>1.8.0.1'
gem 'hashie'
gem 'exception_notification'
gem 'sanger_barcode_format', github: 'sanger/sanger_barcode_format', branch: 'development'

gem 'sequencescape-client-api', require: 'sequencescape'
gem 'pmb-client', '0.1.0', github: 'sanger/pmb-client'

gem 'roo', '~> 2.8.0'

group :development do
  gem 'listen'
  gem 'pry'
  gem 'rubocop', require: false
  gem 'yard', require: false
end

group :test do
  gem 'timecop'
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'launchy'
  gem 'minitest'
  gem 'minitest-rails-capybara'
  gem 'mocha'
  gem 'rails-controller-testing'
  gem 'webdrivers'
end
