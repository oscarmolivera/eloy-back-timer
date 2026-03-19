ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!

  # ====================== NEW: FACTORYBOT ======================
  # Allows `create(:company)`, `create(:user)`, `create(:user, :admin)` etc.
  config.include FactoryBot::Syntax::Methods

  # ====================== NEW: JSON HELPER ======================
  # So you can keep using `json_response` in your request specs
  config.include Module.new {
    def json_response
      JSON.parse(response.body, symbolize_names: true)
    end
  }, type: :request
  # ============================================================
end
