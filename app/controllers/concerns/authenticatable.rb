module Authenticatable
  class AuthenticationError < StandardError; end
  class AuthorizationError < StandardError; end

  def authenticate_user!
    token = request.headers["Authorization"]&.split(" ")&.last
    payload = JwtService.decode(token)

    raise AuthenticationError, "Invalid token" unless payload
    raise AuthenticationError, "Invalid token" unless payload["user_id"]

    @current_user = User.find_by(id: payload["user_id"])
    raise AuthenticationError, "Invalid token" unless @current_user
    raise AuthenticationError, "User inactive" unless @current_user.active?
  rescue JWT::DecodeError, JWT::ExpiredSignature
    raise AuthenticationError, "Invalid or expired token"
  end

  def require_superadmin!
    authenticate_user!
    raise AuthorizationError, "Access denied" unless @current_user.super_admin?
  end

  private

  def current_admin(user_id)
    @current_user ||= User.find_by(id: user_id)
  end
end
