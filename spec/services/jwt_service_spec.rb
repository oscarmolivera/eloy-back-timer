require 'rails_helper'

RSpec.describe JwtService, type: :service do
  let(:payload)    { { user_id: 123, role: "admin" } }
  let(:secret_key) { "test-jwt-secret-key-for-specs-only" }

  before do
    # Stub credentials so the spec doesn't depend on your real `credentials.yml.enc`
    allow(Rails.application.credentials).to receive(:dig)
      .with(:jwt, :secret_key)
      .and_return(secret_key)
  end

  describe ".encode" do
    it "returns a JWT token as a string" do
      token = JwtService.encode(payload)
      expect(token).to be_a(String)
      expect(token.split('.').size).to eq(3) # header.payload.signature
    end

    it "adds expiration time to the payload (default = 15 minutes from now)" do
      token = JwtService.encode(payload)
      decoded = JWT.decode(token, secret_key, true, algorithm: "HS256")[0]

      expect(decoded["exp"]).to be_present
      expect(decoded["exp"]).to be_a(Integer)
      expect(decoded["user_id"]).to eq(123)
    end

    it "accepts a custom expiration time" do
      custom_exp = 7.days.from_now
      token = JwtService.encode(payload, custom_exp)

      decoded = JWT.decode(token, secret_key, true, algorithm: "HS256")[0]
      expect(decoded["exp"]).to eq(custom_exp.to_i)
    end

    it "does not mutate the original payload" do
      original = payload.dup
      JwtService.encode(payload)
      expect(payload).to eq(original)
    end
  end

  describe ".decode" do
    let(:valid_token) { JwtService.encode(payload) }

    context "when the token is valid" do
      it "returns the original payload (with string keys)" do
        result = JwtService.decode(valid_token)

        expect(result).to be_a(Hash)
        expect(result["user_id"]).to eq(123)
        expect(result["role"]).to eq("admin")
        expect(result["exp"]).to be_present
      end
    end

    context "when the token is invalid" do
      it "returns nil" do
        expect(JwtService.decode("this.is.not.a.valid.token")).to be_nil
        expect(JwtService.decode(nil)).to be_nil
        expect(JwtService.decode("")).to be_nil
      end
    end

    context "when the token has expired" do
      it "returns nil" do
        expired_token = JwtService.encode(payload, 1.hour.ago)
        expect(JwtService.decode(expired_token)).to be_nil
      end
    end

    context "when the signature is wrong (tampered token)" do
      it "returns nil" do
        tampered = valid_token[0..-2] + "X" # corrupt the signature
        expect(JwtService.decode(tampered)).to be_nil
      end
    end
  end

  describe "round-trip" do
    it "encode + decode returns the original data" do
      token   = JwtService.encode(payload)
      decoded = JwtService.decode(token)

      expect(decoded["user_id"]).to eq(payload[:user_id])
      expect(decoded["role"]).to    eq(payload[:role])
    end
  end
end
