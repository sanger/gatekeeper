# frozen_string_literal: true

source 'https://rubygems.org'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false
gem 'bootstrap-datepicker-rails'
gem 'bootstrap-sass'
gem 'exception_notification'
gem 'hashie'
gem 'jquery-rails'
gem 'oj', '~> 3.13'
gem 'pmb-client', '0.1.0', github: 'sanger/pmb-client'
gem 'puma'
gem 'rails', '~> 5.2.6'
gem 'roo', '~> 2.8.0'
gem 'sanger_barcode_format', github: 'sanger/sanger_barcode_format', branch: 'development'
gem 'sassc-rails'
gem 'sequencescape-client-api', '0.8.2.pre.rcx', require: 'sequencescape'
gem 'sprint_client'

group :development do
  gem 'listen'
  gem 'pry-rails'
  gem 'uglifier', '>= 1.3.0'
  gem 'yard', require: false
end

group :test, :development do
end

group :lint do
  gem 'rubocop', require: false
  gem 'rubocop-rails', require: false
end

group :test do
  gem 'capybara'
  gem 'capybara-selenium'
  gem 'launchy'
  gem 'minitest'
  gem 'minitest-rails-capybara'
  gem 'mocha'
  gem 'rails-controller-testing'
  gem 'simplecov', require: false
  gem 'timecop'
  gem 'webdrivers'
end
