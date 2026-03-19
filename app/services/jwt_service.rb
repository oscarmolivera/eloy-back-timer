class JwtService
  def self.encode(payload, exp = 15.min.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.credentials.dig(:jwt, :secret_key))
  end

  def self.decode(token)
    decoded = JWT.decode(token, Rails.application.credentials.dig(:jwt, :secret_key))[0]
    HashWithIndifferentAccess.new decoded
  rescue JWT::DecodeError => e
    e.message
  rescue JWT::ExpiredSignature => e
    e.message
  rescue JWT::VerificationError => e
    e.message
  end

  def encode_refresh(payload, exp = 7.days.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, Rails.application.secrets.secret_key_base)
  end
end
