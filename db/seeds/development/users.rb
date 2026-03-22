[
  {
    credential_path: %i[super_admin one],
    first_name: "Alberto",
    last_name: "Sibajoz"
  },
  {
    credential_path: %i[super_admin two],
    first_name: "Cristian",
    last_name: "Astorga"
  },
  {
    credential_path: %i[super_admin tre],
    first_name: "Oscar",
    last_name: "Olivera"
  }
].each do |admin|
  email = Rails.application.credentials.dig(*admin[:credential_path], :email)
  password = Rails.application.credentials.dig(*admin[:credential_path], :password)

  user = User.find_or_initialize_by(email: email)

  if user.new_record?
    user.assign_attributes(
      password: password,
      first_name: admin[:first_name],
      last_name: admin[:last_name],
      active: true,
      role: :super_admin
    )
    user.save!
    puts "  ✅ Created superadmin: #{email}"
  else
    puts "  ⏭️  Skipping — already exists: #{email}"
  end
end
