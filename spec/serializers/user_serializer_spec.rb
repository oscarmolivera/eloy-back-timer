require "rails_helper"

RSpec.describe UserSerializer do
  let(:company) { create(:company) }
  let(:user) do
    create(:user,
           first_name: "Oscar",
           last_name: "Molivera",
           company_id: company.id)
  end

  subject(:json) { described_class.new(user).as_json }

  it "includes the expected fields" do
    expect(json.keys).to contain_exactly(
      :id, :email, :first_name, :last_name, :full_name,
      :role, :active, :last_sign_in_at, :company_id
    )
  end

  it "exposes full_name as a computed field" do
    expect(json[:full_name]).to eq("Oscar Molivera")
  end

  it "never exposes password_digest" do
    expect(json.keys).not_to include(:password_digest)
  end

  it "never exposes created_at or updated_at" do
    expect(json.keys).not_to include(:created_at, :updated_at)
  end

  context "when user has no first or last name" do
    let(:user) { create(:user, first_name: nil, last_name: nil) }

    it "returns nil for full_name" do
      expect(json[:full_name]).to be_nil
    end
  end
end
