puts ""
puts "👤 Seeding Users..."
load Rails.root.join("db/seeds/#{Rails.env}/users.rb")

puts ""
puts "🏢 Seeding Companies..."
load Rails.root.join("db/seeds/#{Rails.env}/companies.rb")

puts ""
puts "✅ Seeding complete for environment: #{Rails.env}"
