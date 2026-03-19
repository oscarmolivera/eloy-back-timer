
User.create!(
  email: "#{Rails.application.credentials.dig(:super_admin, :one, :email)}",
  password: "#{Rails.application.credentials.dig(:super_admin, :one, :password)}",
  first_name: "Name One",
  last_name: "Super Admin One",
  active: true,
  role: :super_admin
)


User.create!(
  email: "#{Rails.application.credentials.dig(:super_admin, :two, :email)}",
  password: "#{Rails.application.credentials.dig(:super_admin, :two, :password)}",
  first_name: "Name Two",
  last_name: "Super Admin Two",
  active: true,
  role: :super_admin
)

User.create!(
  email: "#{Rails.application.credentials.dig(:super_admin, :tre, :email)}",
  password: "#{Rails.application.credentials.dig(:super_admin, :tre, :password)}",
  first_name: "Name Three",
  last_name: "Super Admin Three",
  active: true,
  role: :super_admin
)
