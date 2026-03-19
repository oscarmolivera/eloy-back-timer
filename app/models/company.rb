class Company < ApplicationRecord
  has_many :users

  before_validation :generate_slug, on: :create

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true, format: { with: /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/, message: "only allows lowercase letters, numbers, and hyphens" }

  def generate_slug
    self.slug ||= name.to_s.parameterize
  end
end
