# spec/support/openapi.rb
require "yaml"

OPENAPI_METADATA = YAML.load_file(
  Rails.root.join("spec/support/openapi_metadata.yaml")
).deep_symbolize_keys.freeze

module OpenAPIExampleMetadatas
  def openapi_metadata(key)
    OPENAPI_METADATA.fetch(key) do
      raise KeyError, "OpenAPI metadata not found for #{key.inspect}. " \
                      "Define it in spec/support/openapi_metadata.yaml"
    end
  end
end

def overwrite_openapi_key!(hash, key, value)
  hash[key] = value if hash.key?(key)
  hash[key.to_sym] = value if hash.key?(key.to_sym)
end

def normalize_openapi_examples(value)
  case value
  when Array
    value.map { |item| normalize_openapi_examples(item) }
  when Hash
    normalized = value.transform_values { |v| normalize_openapi_examples(v) }

    overwrite_openapi_key!(normalized, "id", 1)
    overwrite_openapi_key!(normalized, "company_id", 1)
    overwrite_openapi_key!(normalized, "user_id", 1)

    overwrite_openapi_key!(normalized, "created_at", "2026-01-01T00:00:00Z")
    overwrite_openapi_key!(normalized, "updated_at", "2026-01-01T00:00:00Z")
    overwrite_openapi_key!(normalized, "timestamp", "2026-01-01T00:00:00Z")

    overwrite_openapi_key!(normalized, "access_token", "***")
    overwrite_openapi_key!(normalized, "refresh_token", "***")

    normalized
  else
    value
  end
end

RSpec.configure do |config|
  config.include OpenAPIExampleMetadatas
end

if ENV["OPENAPI"].present?
  require "rspec/openapi"

  RSpec::OpenAPI.info = {
    title: "EloyTimer API",
    description: "Employee shift management for the Spanish hospitality industry",
    version: "1.0.0"
  }

  RSpec::OpenAPI.path = "doc/openapi.yaml"

  RSpec::OpenAPI.servers = [
    { url: "https://eloy-back-timer-api-server.onrender.com", description: "Production" },
    { url: "http://localhost:3000", description: "Development" }
  ]

  RSpec::OpenAPI.security_schemes = {
    "BearerAuth" => {
      type: "http",
      scheme: "bearer",
      bearerFormat: "JWT",
      description: "JWT access token obtained after successful login"
    },
    "ApiKeyAuth" => {
      type: "apiKey",
      in: "header",
      name: "X-API-Key",
      description: "Secret API key required on every request"
    }
  }

  RSpec::OpenAPI.post_process_hook = lambda do |_path, _records, spec|
    spec[:security] = [ { "BearerAuth" => [] } ]

    if spec[:responses].is_a?(Hash)
      spec[:responses].each_value do |response|
        next unless response[:content].is_a?(Hash)

        response[:content].each_value do |content|
          next unless content[:example]

          content[:example] = normalize_openapi_examples(content[:example])
        end
      end
    end

    if spec[:requestBody].is_a?(Hash) && spec[:requestBody][:content].is_a?(Hash)
      spec[:requestBody][:content].each_value do |content|
        next unless content[:example]

        content[:example] = normalize_openapi_examples(content[:example])
      end
    end

    spec
  end
end
