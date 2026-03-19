class JwtService
  def self.encode(payload, exp = 15.minutes.from_now)
    payload = payload.dup
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.dig(:jwt, :secret_key))
  end

  def self.decode(token)
    JWT.decode(token, Rails.application.credentials.dig(:jwt, :secret_key))[0]
  rescue JWT::DecodeError, JWT::ExpiredSignature, JWT::VerificationError
    nil
  end
end
