# frozen_string_literal: true

source 'https://rubygems.org'

gem 'bootstrap-sass'
gem 'bootstrap-datepicker-rails'
gem 'hashie'
gem 'jquery-rails'
gem 'puma'
gem 'rails', '~>5.1.2'
gem 'sassc-rails'
gem 'uglifier', '>= 1.3.0'
gem 'exception_notification'
gem 'sanger_barcode_format', github: 'sanger/sanger_barcode_format', branch: 'development'
gem 'sequencescape-client-api', require: 'sequencescape'
gem 'pmb-client', '0.1.0', github: 'sanger/pmb-client'
gem 'roo', '~> 2.8.0'

group :development do
  gem 'listen'
  gem 'pry-rails'
  gem 'yard', require: false
end

group :test, :development do
end

group :lint do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
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
  gem 'simplecov', require: false
  gem 'webdrivers'
end
