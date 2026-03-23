require "rails_helper"

RSpec.describe CompanyDetailSerializer do
  let(:company) { create(:company) }

  subject(:json) { described_class.new(company).as_json }

  it "includes all fields including timestamps" do
    expect(json.keys).to include(
      :id, :name, :slug, :active, :created_at, :updated_at
    )
  end

  it "formats timestamps as ISO 8601" do
    expect(json[:created_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
    expect(json[:updated_at]).to match(/\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}/)
  end
end
