require 'rails_helper'
RSpec.describe "API::V1::Auth", type: :request do
  let(:company) { create(:company) }
  let(:user) { create(:user, company: company) }

  describe "POST /login" do
    context "with valid credentials" do
      it "returns 200 and tokens" do
        post "/api/v1/login", params: { email: user.email, password: user.password }
        expect(response).to have_http_status(200)
        expect(json_response).to include("access_token", "refresh_token")
      end
    end

    context "with wrong password" do
      it "returns 401" do
        post "/api/v1/login", params: { email: user.email, password: "wrongpassword" }
        expect(response).to have_http_status(401)
      end
    end

    context "with unknown email" do
      it "returns 401" do
        post "/api/v1/login", params: { email: "unknown@example.com", password: user.password }
        expect(response).to have_http_status(401)
      end
    end
    context "with inactive user" do
      let(:inactive_user) { create(:user, company: company, active: false) }

      it "returns 403" do
        post "/api/v1/login", params: { email: inactive_user.email, password: inactive_user.password }
        expect(response).to have_http_status(403)
      end
    end
  end

  describe "POST /refresh" do
    let(:refresh_token) { JsonWebToken.encode({ user_id: user.id }, 7.days.from_now) }

    context "with valid token" do
      it "returns 200 and new access token" do
        post "/api/v1/refresh", headers: { "Authorization" => "Bearer #{refresh_token}" }
        expect(response).to have_http_status(200)
        expect(json_response).to include("access_token")
      end
    end

    context "with expired token" do
      let(:expired_token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.ago) }

      it "returns 401" do
        post "/api/v1/refresh", headers: { "Authorization" => "Bearer #{expired_token}" }
        expect(response).to have_http_status(401)
      end
    end
  end

  describe "DELETE /logout" do
    let(:access_token) { JsonWebToken.encode({ user_id: user.id }, 1.hour.from_now) }

    it "returns 204" do
      delete "/api/v1/logout", headers: { "Authorization" => "Bearer #{access_token}" }
      expect(response).to have_http_status(204)
    end
  end
end