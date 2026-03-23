require "rails_helper"

RSpec.describe CompanySerializer do
  let(:company) { create(:company, name: "Restaurante Casa Galicia") }

  subject(:json) { described_class.new(company).as_json }

  it "includes the expected fields" do
    expect(json.keys).to contain_exactly(
      :id, :name, :business_name, :slug, :cif, :ccc,
      :logo_url, :city, :province, :postal_code, :street,
      :number, :floor, :door, :contact_email,
      :contact_phone_main, :contact_phone_secondary, :active
    )
  end

  it "never exposes created_at or updated_at" do
    expect(json.keys).not_to include(:created_at, :updated_at)
  end

  describe ".collection" do
    let(:companies) { create_list(:company, 3) }

    it "serializes a collection" do
      result = described_class.collection(companies)
      expect(result).to be_an(Array)
      expect(result.size).to eq(3)
      expect(result.first.keys).to include(:id, :name, :slug)
    end
  end
end
