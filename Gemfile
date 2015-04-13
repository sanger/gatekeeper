# A sample Gemfile
# We use http rather than https due to difficulties navigating the proxy otherwise
source "http://rubygems.org"

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

gem 'sequencescape-client-api',
  :github     => 'sanger/sequencescape-client-api',
  :branch  => 'rails_4',
  :require => 'sequencescape'
gem 'sanger_barcode',
  :github => 'sanger/sanger_barcode'

group :development do
  gem "pry"
end

group :deployment do
  gem "psd_logger", :github => "sanger/psd_logger"
end

group :test do
  gem 'mocha'
end
