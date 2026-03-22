source "https://rubygems.org"

gem "bootsnap", require: false
gem "bcrypt"
gem "jwt"
gem "kamal", require: false
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "rails", "~> 8.1.2"
gem "rack-cors"
gem "solid_cache"
gem "solid_queue"
gem "thruster", require: false
gem "tzinfo-data", platforms: %i[ windows jruby ]

group :development, :test do
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "dotenv-rails"
  gem "factory_bot_rails"
  gem "faker"
  gem "rspec-openapi"
  gem "rspec-rails"
  gem "rubocop-rails-omakase", require: false
end

group :development do
  gem "pry-rails"
end

group :production do
  gem "net-pop", github: "ruby/net-pop"
end
