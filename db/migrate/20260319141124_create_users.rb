class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.integer :role, null: false, default: 0
      t.string :first_name
      t.string :last_name
      t.boolean :active, default: true
      t.bigint :company_id, index: true
      t.datetime :last_sign_in_at
      t.timestamps
    end
  end
end
