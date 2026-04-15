class Rack::Attack
  # Throttle all requests by IP (60 requests per minute)
  throttle("req/ip", limit: 60, period: 1.minute) do |req|
    req.ip
  end

  # Throttle login attempts (5 per 20 seconds per IP)
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    req.ip if req.path == "/api/v1/auth/login" && req.post?
  end

  # Block abusive IPs (optional — ban after 300 requests in 5 minutes)
  blocklist("fail2ban") do |req|
    Rack::Attack::Allow2Ban.filter(req.ip, maxretry: 300, findtime: 5.minutes, bantime: 1.hour) do
      true
    end
  end

  # Custom response for throttled requests
  self.throttled_responder = lambda do |req|
    [429, { "Content-Type" => "application/json" }, [{ error: "Rate limit exceeded" }.to_json]]
  end
  end