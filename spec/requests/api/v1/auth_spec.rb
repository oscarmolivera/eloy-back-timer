require 'rails_helper'

RSpec.describe "API::V1::Auth", type: :request do
  let(:password) { "password123" }
  let(:user)     { create(:user, password: password) }
  let(:api_key)  { Rails.application.credentials.dig(:api, :secret_key) }

  describe "POST /api/v1/auth/login", openapi: OPENAPI_METADATA[:auth_login] do
    context "with valid credentials" do
      it "returns 200 and tokens" do
        post "/api/v1/auth/login",
             params: { email: user.email, password: password },
             headers: { "X-API-Key" => api_key }

        expect(response).to have_http_status(200)
        expect(json_response).to include(:access_token, :refresh_token)
      end
    end

    context "with wrong password" do
      it "returns 401" do
        post "/api/v1/auth/login",
             params: { email: user.email, password: "wrongpassword" },
             headers: { "X-API-Key" => api_key }

        expect(response).to have_http_status(401)
      end
    end

    context "with unknown email" do
      it "returns 401" do
        post "/api/v1/auth/login",
             params: { email: "unknown@example.com", password: password },
             headers: { "X-API-Key" => api_key }

        expect(response).to have_http_status(401)
      end
    end

    context "with inactive user" do
      let(:inactive_user) { create(:user, :inactive, password: password) }

      it "returns 403" do
        post "/api/v1/auth/login",
             params: { email: inactive_user.email, password: password },
             headers: { "X-API-Key" => api_key }

        expect(response).to have_http_status(403)
      end
    end
  end

  describe "POST /api/v1/auth/refresh", openapi: OPENAPI_METADATA[:auth_refresh] do
    let(:refresh_token) { JwtService.encode({ user_id: user.id }, 7.days.from_now) }

    context "with valid token" do
      it "returns 200 and new access token" do
        post "/api/v1/auth/refresh",
             headers: {
               "Authorization" => "Bearer #{refresh_token}",
               "X-API-Key"     => api_key
             }

        expect(response).to have_http_status(200)
        expect(json_response).to have_key(:access_token)
      end
    end

    context "with expired token" do
      let(:expired_token) { JwtService.encode({ user_id: user.id }, 1.hour.ago) }

      it "returns 401" do
        post "/api/v1/auth/refresh",
             headers: {
               "Authorization" => "Bearer #{expired_token}",
               "X-API-Key"     => api_key
             }

        expect(response).to have_http_status(401)
      end
    end
  end

  describe "DELETE /api/v1/auth/logout", openapi: OPENAPI_METADATA[:auth_logout] do
    let(:access_token) { JwtService.encode({ user_id: user.id }, 1.hour.from_now) }

    it "returns 204" do
      delete "/api/v1/auth/logout",
             headers: {
               "Authorization" => "Bearer #{access_token}",
               "X-API-Key"     => api_key
             }

      expect(response).to have_http_status(204)
    end
  end
end
