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
gem 'bootstrap-datepicker-rails', '~>1.6.4.1'
gem 'hashie'
gem 'exception_notification'

gem 'sequencescape-client-api',
    github: 'sanger/sequencescape-client-api',
    branch: 'rails_4',
    require: 'sequencescape'
gem 'sanger_barcode',
    github: 'sanger/sanger_barcode'

group :development do
  gem 'pry'
  gem 'yard', require: false
  gem 'rubocop', require: false
  gem 'listen'
end

group :deployment do
  gem 'psd_logger', github: 'sanger/psd_logger'
end

group :test do
  gem 'minitest'
  gem 'mocha'
  gem 'poltergeist'
  gem 'launchy'
  gem 'minitest-rails-capybara'
  gem 'rails-controller-testing'
end
