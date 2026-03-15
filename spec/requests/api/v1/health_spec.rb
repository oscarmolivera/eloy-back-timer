require "rails_helper"

RSpec.describe "Api::V1::Health", type: :request do
  describe "GET /api/v1/health" do
    context "with no API key" do
      it "returns 401 unauthorized" do
        get "/api/v1/health"
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns an error message" do
        get "/api/v1/health"
        expect(response.parsed_body["error"]).to eq("Unauthorized")
      end
    end

    context "with a wrong API key" do
      it "returns 401 unauthorized" do
        get "/api/v1/health", headers: { "X-API-Key" => "wrongkey" }
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "with the correct API key" do
      let(:api_key) { Rails.application.credentials.dig(:api, :secret_key) }

      it "returns 200 ok" do
        get "/api/v1/health", headers: { "X-API-Key" => api_key }
        expect(response).to have_http_status(:ok)
      end

      it "returns connected database status" do
        get "/api/v1/health", headers: { "X-API-Key" => api_key }
        expect(response.parsed_body["status"]).to eq("ok")
        expect(response.parsed_body["database"]).to eq("connected")
      end
    end
  end
end
