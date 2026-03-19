puts "Seeding Users..."
load Rails.root.join("db/seeds/#{Rails.env}/users.rb")

puts "Seeding Companies..."
load Rails.root.join("db/seeds/#{Rails.env}/companies.rb")
