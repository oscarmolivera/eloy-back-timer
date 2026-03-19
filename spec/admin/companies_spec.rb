require 'rails_helper'

RSpec.describe "API::V1::Admin::Companies", type: :request do
  let(:api_key) { Rails.application.credentials.dig(:api, :secret_key) }
  let(:super_admin)   { create(:user, :super_admin) }
  let(:token)   { JwtService.encode({ user_id: super_admin.id }, 1.hour.from_now) }

  let(:headers) do
    {
      "X-API-Key"     => api_key,
      "Authorization" => "Bearer #{token}"
    }
  end

  describe "GET /api/v1/admin/companies" do
    it "returns a list of all companies" do
      create_list(:company, 3)

      get "/api/v1/admin/companies", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response).to be_an(Array)
      expect(json_response.size).to eq(3)
    end
  end

  describe "POST /api/v1/admin/companies" do
    it "creates a new company" do
      expect do
        post "/api/v1/admin/companies",
             params: { company: { name: "New Test Company" } },
             headers: headers
      end.to change(Company, :count).by(1)

      expect(response).to have_http_status(:created)
      expect(json_response).to include(:id, :name, :slug)
      expect(Company.last.name).to eq("New Test Company")
    end
  end

  describe "GET /api/v1/admin/companies/:id" do
    let(:company) { create(:company) }

    it "returns a single company" do
      get "/api/v1/admin/companies/#{company.id}", headers: headers

      expect(response).to have_http_status(:ok)
      expect(json_response).to include(:id, :name, :slug)
    end
  end

  describe "PUT /api/v1/admin/companies/:id" do
    let(:company) { create(:company) }

    it "updates a company" do
      put "/api/v1/admin/companies/#{company.id}",
          params: { company: { name: "Updated Company Name" } },
          headers: headers

      expect(response).to have_http_status(:ok)
      expect(company.reload.name).to eq("Updated Company Name")
    end
  end

  describe "DELETE /api/v1/admin/companies/:id" do
    let(:company) { create(:company) }

    it "deletes a company" do
      delete "/api/v1/admin/companies/#{company.id}", headers: headers

      expect(response).to have_http_status(:no_content)
      expect(company.reload.active).to be_falsey
    end
  end
end
