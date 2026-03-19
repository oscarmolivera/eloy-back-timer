require 'rails_helper'

RSpec.describe Company, type: :model do
  let(:company) { build(:company) }

  describe "validations" do
    it "is valid with valid attributes" do
      expect(company).to be_valid
    end

    it "validates presence of name" do
      company.name = nil
      expect(company).not_to be_valid
      expect(company.errors[:name]).to include("can't be blank")
    end

    it "validates presence of slug (fails when name is also blank)" do
      company.name = nil
      company.slug = nil
      expect(company).not_to be_valid
      expect(company.errors[:slug]).to include("can't be blank")
    end

    it "validates uniqueness of slug" do
      create(:company, slug: "acme-corp")
      duplicate = build(:company, slug: "acme-corp")
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:slug]).to include("has already been taken")
    end
  end

  describe "associations" do
    it { expect(Company.reflect_on_association(:users).macro).to eq(:has_many) }
  end

  describe "callbacks" do
    it "generates slug from name before validation when slug is blank" do
      company = build(:company, name: "My Awesome Company", slug: nil)
      company.valid?
      expect(company.slug).to eq("my-awesome-company")
    end

    it "does not override slug if already provided" do
      company = build(:company, name: "My Company", slug: "custom-slug")
      company.valid?
      expect(company.slug).to eq("custom-slug")
    end
  end

  describe "slug format" do
    it "accepts valid slug format" do
      valid_slugs = %w[acme acme-corp acme-corp-2025 mycompany123]
      valid_slugs.each do |slug|
        company.slug = slug
        expect(company).to be_valid
      end
    end

    it "rejects invalid slug format" do
      invalid_slugs = [ "Acme Corp", "acme_corp", "acme!", "acme corp", "Acme-Corp" ]
      invalid_slugs.each do |slug|
        company.slug = slug
        expect(company).not_to be_valid
        expect(company.errors[:slug]).to include("only allows lowercase letters, numbers, and hyphens")
      end
    end
  end
end
