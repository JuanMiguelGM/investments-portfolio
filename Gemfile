source "https://rubygems.org"

gem "rails", "~> 8.1.1"
gem "propshaft"
gem "sqlite3", ">= 2.1"
gem "puma", ">= 5.0"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "tailwindcss-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[windows jruby]
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"
gem "bootsnap", require: false
gem "kamal", require: false
gem "thruster", require: false
gem "image_processing", "~> 1.2"

# Charts and time-series
gem "chartkick"
gem "groupdate"

# CSV parsing (removed from Ruby stdlib in 3.4)
gem "csv"

# HTTP client for Yahoo Finance
gem "faraday"
gem "faraday-retry"

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false

  # Testing
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "shoulda-matchers"
  gem "webmock"

  # Linting
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rspec", require: false
  gem "rubocop-performance", require: false
end

group :development do
  gem "web-console"
end
