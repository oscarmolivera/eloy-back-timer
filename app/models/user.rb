class User < ApplicationRecord
  has_secure_password

  belongs_to :company

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true

  enum :role, { user: 0, admin: 1, super_admin: 2 }
end
