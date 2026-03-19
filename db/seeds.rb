env_seed_file = Rails.root.join("db", "seeds", "#{Rails.env}", "env_seeds.rb")

puts "Seeding for environment: #{Rails.env}"
load(env_seed_file) if File.exist?(env_seed_file)
