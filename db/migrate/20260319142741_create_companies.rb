class CreateCompanies < ActiveRecord::Migration[8.1]
  def change
    create_table :companies do |t|
      t.string :name, null: false
      t.string :slug, null: false, index: { unique: true }
      t.string :business_name
      t.string :ccc
      t.string :cif
      t.string :contact_email
      t.string :contact_phone_main
      t.string :contact_phone_secondary
      t.string :street
      t.string :number
      t.string :floor
      t.string :door
      t.string :city
      t.string :postal_code
      t.string :province
      t.string :logo_url
      t.boolean :active, default: true, index: true

      t.timestamps
    end
  end
end
