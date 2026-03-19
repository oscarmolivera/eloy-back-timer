require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { build(:user) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "validates presence of email" do
      user.email = nil
      expect(user).not_to be_valid
      expect(user.errors[:email]).to include("can't be blank")
    end

    it "validates uniqueness of email" do
      create(:user, email: "test@example.com")
      duplicate = build(:user, email: "test@example.com")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:email]).to include("has already been taken")
    end

    it "rejects invalid email formats" do
      invalid_user = build(:user, email: "plainaddress")
      expect(invalid_user).not_to be_valid
      expect(invalid_user.errors[:email]).to include("is invalid")
    end

    it "validates presence of role" do
      user.role = nil
      expect(user).not_to be_valid
      expect(user.errors[:role]).to include("can't be blank")
    end
  end

  describe "associations" do
    it { expect(User.reflect_on_association(:company).macro).to eq(:belongs_to) }
  end

  describe "enum :role" do
    it "defines the roles correctly" do
      expect(User.roles).to eq({ "user" => 0, "admin" => 1, "super_admin" => 2 })
    end

    it "has predicate methods" do
      expect(create(:user, :admin).admin?).to be true
      expect(create(:user, :super_admin).super_admin?).to be true
    end
  end

  describe "password (has_secure_password)" do
    let(:valid_user) { create(:user, password: "password123", password_confirmation: "password123") }

    it "authenticates with correct password" do
      expect(valid_user.authenticate("password123")).to be_truthy
    end

    it "does not authenticate with wrong password" do
      expect(valid_user.authenticate("wrongpass")).to be_falsey
    end

    it "requires password and password_confirmation to match" do
      invalid_user = build(:user, password: "password123", password_confirmation: "different")
      expect(invalid_user).not_to be_valid
    end
  end
end
