class Api::V1::AuthController < Api::V1::BaseController
  skip_before_action :verify_api_key, only: [ :login ]

  def login
    user = User.find_by(email: params[:email])

    if user&.authenticate(params[:password])
      if user.active?
        access_token  = JwtService.encode({ user_id: user.id }, 15.minutes.from_now)
        refresh_token = JwtService.encode({ user_id: user.id }, 7.days.from_now)

        render json: AuthSerializer.new(
          access_token:  access_token,
          refresh_token: refresh_token,
          user:          user
        ).as_json
      else
        render json: ErrorSerializer.new(
          message: "Account is inactive",
          status:  403
        ).as_json, status: :forbidden
      end
    else
      render json: ErrorSerializer.new(
        message: "Invalid email or password",
        status:  401
      ).as_json, status: :unauthorized
    end
  end

  def refresh
    token   = request.headers["Authorization"]&.split(" ")&.last
    payload = JwtService.decode(token)

    if payload && payload["user_id"]
      access_token = JwtService.encode({ user_id: payload["user_id"] }, 15.minutes.from_now)
      render json: { access_token: access_token }
    else
      render json: ErrorSerializer.new(
        message: "Invalid refresh token",
        status:  401
      ).as_json, status: :unauthorized
    end
  end

  def logout
    head :no_content
  end
end
