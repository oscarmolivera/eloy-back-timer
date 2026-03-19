require 'rails_helper'

RSpec.describe "Admin::Companies", type: :request do
  let(:superadmin) { create(:user, role: "superadmin") }
  let(:company) { create(:company) }

  describe "GET /admin/companies" do
    context "without authentication" do
      it "returns 401" do
        get "/admin/companies"
        expect(response).to have_http_status(401)
      end
    end

    context "with non-superadmin user" do
      let(:user) { create(:user, company: company, role: "employee") }

      it "returns 403" do
        sign_in user
        get "/admin/companies"
        expect(response).to have_http_status(403)
      end
    end

    context "with superadmin user" do
      it "returns 200 and list of companies" do
        sign_in superadmin
        get "/admin/companies"
        expect(response).to have_http_status(200)
        expect(json_response).to be_an(Array)
      end
    end
  end

  describe "POST /admin/companies" do
    let(:valid_params) do
      {
        name: "New Company",
        business_name: "New Company S.L.",
        ccc: "1234567890",
      }
    end
    context "with superadmin user" do
      it "creates a new company and returns 201" do
        sign_in superadmin
        expect {
          post "/admin/companies", params: valid_params
        }.to change(Company, :count).by(1)
        expect(response).to have_http_status(201)
        expect(json_response["name"]).to eq("New Company")
      end

      it "returns 422 with invalid params" do
        sign_in superadmin
        post "/admin/companies", params: { name: "" }
        expect(response).to have_http_status(422)
        expect(json_response["errors"]).to include("Name can't be blank")
      end
    end
  end
  describe "PATCH /admin/companies/:id" do
    let(:valid_params) { { name: "Updated Company Name" } }

    context "with superadmin user" do
      it "updates the company and returns 200" do
        sign_in superadmin
        patch "/admin/companies/#{company.id}", params: valid_params
        expect(response).to have_http_status(200)
        expect(json_response["name"]).to eq("Updated Company Name")
      end

      it "returns 422 with invalid params" do
        sign_in superadmin
        patch "/admin/companies/#{company.id}", params: { name: "" }
        expect(response).to have_http_status(422)
        expect(json_response["errors"]).to include("Name can't be blank")
      end
    end
  end

  describe "DELETE /admin/companies/:id" do
    context "with superadmin user" do
      it "deactivates the company and returns 200" do
        sign_in superadmin
        delete "/admin/companies/#{company.id}"
        expect(response).to have_http_status(200)
        expect(company.reload.active).to eq(false)
      end
    end
  end
end
