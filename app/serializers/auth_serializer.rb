class AuthSerializer
  def initialize(access_token:, refresh_token:, user:)
    @access_token  = access_token
    @refresh_token = refresh_token
    @user          = user
  end

  def as_json
    {
      access_token:  @access_token,
      refresh_token: @refresh_token,
      user:          UserSerializer.new(@user).as_json
    }
  end
end
