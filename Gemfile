# A sample Gemfile
# We use http rather than https due to difficulties navigating the proxy otherwise
source "http://rubygems.org"

gem 'sinatra'
gem 'sinatra-partial'
gem 'puma'
gem 'erubis'
gem 'compass'

gem 'sequencescape-client-api',
  :git     => 'git+ssh://git@github.com/sanger/sequencescape-client-api.git',
  :branch  => 'production',
  :require => 'sequencescape'
gem 'sanger_barcode',
  :git     => 'git+ssh://git@github.com/sanger/sanger_barcode.git'

group :development do
  gem "pry"
end
