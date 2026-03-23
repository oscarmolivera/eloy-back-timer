class UserSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      id:              @user.id,
      email:           @user.email,
      first_name:      @user.first_name,
      last_name:       @user.last_name,
      full_name:       full_name,
      role:            @user.role,
      active:          @user.active,
      last_sign_in_at: @user.last_sign_in_at&.iso8601,
      company_id:      @user.company_id
    }
  end

  private

  def full_name
    [ @user.first_name, @user.last_name ].compact.join(" ").strip.presence
  end
end
