module Authenticatable

  def authenticate_user!
    token = request.headers['Authorization']&.split(' ')&.last
    payload = JwtService.decode(token)
    @current_user = current_admin(payload['user_id'])

    raise AuthenticationError, 'Invalid token' unless @current_user
    raise AuthenticationError, 'User inactive' unless @current_user.active?
  rescue JWT::DecodeError, JWT::ExpiredSignature
    raise AuthenticationError, 'Invalid or expired token'
  end

  def require_superadmin!
    authenticate_user!
    raise AuthorizationError, 'Access denied' unless @current_user.superadmin?
  end

  private

  def current_admin(payload_user_id)
    @current_user ||= User.find_by(id: payload_user_id)
  end
end
