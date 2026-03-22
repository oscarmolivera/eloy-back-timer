# spec/support/openapi.rb

require 'yaml'

OPENAPI_METADATA = YAML.load_file(Rails.root.join('spec/support/openapi_metadata.yaml')).deep_symbolize_keys.freeze

if ENV['OPENAPI'].present?
  require 'rspec/openapi'

  RSpec::OpenAPI.info = {
    title: 'EloyTimer API',
    description: 'Employee shift management for the Spanish hospitality industry',
    version: '1.0.0'
  }

  RSpec::OpenAPI.path = 'doc/openapi.yaml'

  RSpec::OpenAPI.servers = [
    { url: 'https://eloy-back-timer-api-server.onrender.com', description: 'Production' },
    { url: 'http://localhost:3000', description: 'Development' }
  ]

  # ──────────────────────────────────────────────────────────────
  # NEW: Define the two security schemes permanently
  # ──────────────────────────────────────────────────────────────
  RSpec::OpenAPI.security_schemes = {
    'BearerAuth' => {
      type: 'http',
      scheme: 'bearer',
      bearerFormat: 'JWT',
      description: 'JWT access token obtained after successful login'
    },
    'ApiKeyAuth' => {
      type: 'apiKey',
      in: 'header',
      name: 'X-API-Key',
      description: 'Secret API key (used for health check and documentation)'
    }
  }

  # ──────────────────────────────────────────────────────────────
  # NEW: Global security requirement → Redoc lock icon appears everywhere
  # (We default to BearerAuth because that's what your real API endpoints use)
  # ──────────────────────────────────────────────────────────────
  RSpec::OpenAPI.post_process_hook = lambda do |_path, _records, spec|
    spec[:security] = [ { 'BearerAuth' => [] } ]
    spec
  end

  module OpenAPIExampleMetadatas
    def openapi_metadata(key)
      OPENAPI_METADATA.fetch(key) do
        raise KeyError, "OpenAPI metadata not found for #{key.inspect}. " \
                      "Define it in OPENAPI_METADATA."
      end
    end
  end

  RSpec.configure do |config|
    config.include OpenAPIExampleMetadatas
  end
end
