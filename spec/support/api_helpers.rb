def auth_headers(user)
  {
    "X-API-Key"     => ENV.fetch("TEST_API_KEY") { Rails.application.credentials.dig(:api, :secret_key) },
    "Authorization" => "Bearer #{JwtService.encode({ user_id: user.id }, 1.hour.from_now)}"
  }
end