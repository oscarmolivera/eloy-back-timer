ENV["RAILS_ENV"] ||= "test"
require "spec_helper"
require File.expand_path("../config/environment", __dir__)
require "rspec/rails"

abort("The Rails environment is running in production mode!") if Rails.env.production?

Dir[Rails.root.join("spec", "support", "**", "*.rb")].sort.each { |f| require f }

RSpec.configure do |config|
  config.fixture_paths = [
    Rails.root.join("spec/fixtures")
  ]
  config.use_transactional_fixtures = true
  config.filter_rails_from_backtrace!

  # ====================== FACTORY BOT ======================
  config.include FactoryBot::Syntax::Methods

  # ====================== REQUEST HELPERS ======================
  config.include Module.new {
    # Parse JSON response body
    def json_response
      JSON.parse(response.body, symbolize_names: true)
    end

    # Base API key header — use for unauthenticated endpoints
    def api_headers(extra = {})
      {
        "X-API-Key" => Rails.application.credentials.dig(:api, :secret_key)
      }.merge(extra)
    end

    # Full auth headers — API key + JWT Bearer token
    # Usage: get "/api/v1/admin/companies", headers: auth_headers(super_admin)
    def auth_headers(user, extra = {})
      token = JwtService.encode({ user_id: user.id })
      api_headers({ "Authorization" => "Bearer #{token}" }.merge(extra))
    end
  }, type: :request
  # =========================================================
end
