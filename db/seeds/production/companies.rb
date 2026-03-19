require "faker"
5.times do |i|
  Company.create!(
    name: Faker::Company.name,
    business_name: Faker::Company.name + " S.L.",
    ccc: Faker::Number.number(digits: 10),
    cif: "B#{Faker::Number.number(digits: 8)}",
    city: Faker::Address.city,
    contact_email: Faker::Internet.email,
    contact_phone_main: Faker::PhoneNumber.phone_number,
    contact_phone_secondary: Faker::PhoneNumber.phone_number,
    door: Faker::Address.building_number,
    floor: "#{Faker::Address.building_number}º",
    logo_url: Faker::Avatar.image,
    number: Faker::Address.street_address,
    postal_code: Faker::Address.postcode,
    province: Faker::Address.state,
    street: Faker::Address.street_name,
    active: true
  )
end
