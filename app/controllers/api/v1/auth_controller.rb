class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :verify_api_key, only: [ :login ]

  def login
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      if user.active?
        access_token = JwtService.encode({ user_id: user.id }, 15.minutes.from_now)
        refresh_token = JwtService.encode({ user_id: user.id }, 7.days.from_now)
        render json: { access_token: access_token, refresh_token: refresh_token, user: { id: user.id, email: user.email, role: user.role } }
      else
        render json: { error: "Account is inactive" }, status: :forbidden
      end
    else
      render json: { error: "Invalid email or password" }, status: :unauthorized
    end
  end

  def refresh
    token = request.headers["Authorization"]&.split(" ")&.last
    payload = JwtService.decode(token)

    if payload && payload["user_id"]
      access_token = JwtService.encode({ user_id: payload["user_id"] }, 15.minutes.from_now)
      render json: { access_token: access_token }
    else
      render json: { error: "Invalid refresh token" }, status: :unauthorized
    end
  end

  def logout
    # Implement token invalidation logic here (e.g., add to blocklist)
    head :no_content
  end
end
