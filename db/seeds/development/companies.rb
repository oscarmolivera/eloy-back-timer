# db/seeds/development/companies.rb
require "faker"

SEED_COMPANIES = [
  {
    name: "Restaurante Casa Galicia",
    business_name: "Casa Galicia S.L.",
    ccc: "1234567890",
    cif: "B12345678",
    city: "Ourense",
    contact_email: "hola@casagalicia.es",
    contact_phone_main: "+34 988 123 456",
    contact_phone_secondary: "+34 988 123 457",
    door: "2",
    floor: "1º",
    logo_url: "https://placehold.co/200x200?text=CG",
    number: "15",
    postal_code: "32001",
    province: "Ourense",
    street: "Rúa do Paseo",
    active: true
  },
  {
    name: "Hotel Miño",
    business_name: "Hoteles Miño S.L.",
    ccc: "0987654321",
    cif: "B87654321",
    city: "Ourense",
    contact_email: "info@hotelmino.es",
    contact_phone_main: "+34 988 654 321",
    contact_phone_secondary: "+34 988 654 322",
    door: "1",
    floor: "PB",
    logo_url: "https://placehold.co/200x200?text=HM",
    number: "42",
    postal_code: "32003",
    province: "Ourense",
    street: "Avenida de Galicia",
    active: true
  },
  {
    name: "Cafetería O Portiño",
    business_name: "Portiño 2010 S.L.",
    ccc: "1122334455",
    cif: "B11223344",
    city: "Vigo",
    contact_email: "portino@gmail.com",
    contact_phone_main: "+34 986 111 222",
    contact_phone_secondary: "+34 986 111 223",
    door: "3",
    floor: "BJ",
    logo_url: "https://placehold.co/200x200?text=OP",
    number: "8",
    postal_code: "36201",
    province: "Pontevedra",
    street: "Rúa Príncipe",
    active: true
  },
  {
    name: "Pensión A Reconquista",
    business_name: "A Reconquista Hostelería S.L.",
    ccc: "5544332211",
    cif: "B55443322",
    city: "Ourense",
    contact_email: "reconquista@pension.es",
    contact_phone_main: "+34 988 777 888",
    contact_phone_secondary: "+34 988 777 889",
    door: "1",
    floor: "1º",
    logo_url: "https://placehold.co/200x200?text=AR",
    number: "1",
    postal_code: "32002",
    province: "Ourense",
    street: "Praza Maior",
    active: true
  },
  {
    name: "Mesón O Galo",
    business_name: "O Galo Restauración S.L.",
    ccc: "9988776655",
    cif: "B99887766",
    city: "Santiago de Compostela",
    contact_email: "ogalo@meson.es",
    contact_phone_main: "+34 981 333 444",
    contact_phone_secondary: "+34 981 333 445",
    door: "4",
    floor: "PB",
    logo_url: "https://placehold.co/200x200?text=OG",
    number: "22",
    postal_code: "15701",
    province: "A Coruña",
    street: "Rúa do Franco",
    active: true
  }
].freeze

SEED_COMPANIES.each do |attrs|
  company = Company.find_or_initialize_by(cif: attrs[:cif])

  if company.new_record?
    company.assign_attributes(attrs)
    company.save!
    puts "  ✅ Created company: #{attrs[:name]}"
  else
    puts "  ⏭️  Skipping — already exists: #{attrs[:name]}"
  end
end
