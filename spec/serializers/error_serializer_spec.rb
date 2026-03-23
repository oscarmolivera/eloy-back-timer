require "rails_helper"

RSpec.describe ErrorSerializer do
  describe "#as_json" do
    subject(:json) do
      described_class.new(message: "Not found", status: 404).as_json
    end

    it "includes error, message and status" do
      expect(json.keys).to contain_exactly(:error, :message, :status)
    end

    it "maps status code to HTTP status text" do
      expect(json[:error]).to eq("Not Found")
    end

    it "includes the message" do
      expect(json[:message]).to eq("Not found")
    end

    context "with details" do
      subject(:json) do
        described_class.new(
          message: "Validation failed",
          status:  422,
          details: { name: [ "can't be blank" ] }
        ).as_json
      end

      it "includes details" do
        expect(json[:details]).to eq({ name: [ "can't be blank" ] })
      end
    end
  end

  describe ".validation" do
    let(:company) { build(:company, name: nil) }

    before { company.valid? }

    it "returns a validation error hash" do
      result = described_class.validation(company.errors)
      expect(result[:message]).to eq("Validation failed")
      expect(result[:status]).to eq(422)
      expect(result[:details]).to be_a(Hash)
    end
  end
end
