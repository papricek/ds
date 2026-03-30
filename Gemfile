source "https://rubygems.org"
ruby "3.2.2"

gem "rails", "~> 8.0.4"
gem "sprockets-rails"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "bootsnap", require: false

gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "sassc-rails"
gem "bootstrap"
gem "premailer-rails"

gem "bcrypt", "~> 3.1.7"
gem "pundit", "~> 2.2"
gem "simple_command"
gem "redis"
gem "sidekiq"
gem "sidekiq-scheduler"

gem "kaminari"
gem "bootstrap5-kaminari-views"
gem "wicked_pdf"
gem "wkhtmltopdf-binary"
gem "rqrcode"
gem "image_processing", "~> 1.2"
gem "aws-sdk-s3"

gem "sentry-ruby"
gem "sentry-rails"

gem "tzinfo-data", platforms: %i[windows jruby]
gem "kamal", require: false
gem "thruster", require: false

group :development, :test do
  gem "debug", platforms: %i[mri windows], require: "debug/prelude"
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "web-console"
  gem "letter_opener_web"
end

group :test do
  gem "factory_bot_rails"
  gem "faker"
  gem "capybara"
  gem "cuprite"
end
