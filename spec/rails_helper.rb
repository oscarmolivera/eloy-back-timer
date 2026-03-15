ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

# Add additional requires below this line. Rails is not loaded until this point!

RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  config.use_transactional_fixtures = true

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
end
