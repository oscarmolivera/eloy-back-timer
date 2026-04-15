module Api
  module V1
    module Admin
      class CompaniesController < Api::V1::BaseController
        before_action :authenticate_user!
        before_action :require_superadmin!
        before_action :set_company, only: %i[show update destroy]

        def index
          companies = Company.order(:created_at)
          render json: CompanySerializer.collection(companies)
        end

        def show
          render json: CompanyDetailSerializer.new(@company).as_json
        end

        def show_by_slug
          company = Company.find_by(slug: params[:slug])
          if company
            render json: CompanyDetailSerializer.new(company).as_json
          else
            render json: ErrorSerializer.new(
              message: "Company not found",
              status: 404
            ).as_json, status: :not_found
          end
        end

        def create
          company = Company.new(company_params)
          if company.save
            render json: CompanyDetailSerializer.new(company).as_json,
                   status: :created
          else
            render json: ErrorSerializer.validation(company.errors),
                   status: :unprocessable_entity
          end
        end

        def update
          if @company.update(company_params)
            render json: CompanyDetailSerializer.new(@company).as_json
          else
            render json: ErrorSerializer.validation(@company.errors),
                   status: :unprocessable_entity
          end
        end

        def destroy
          if @company.update(active: false)
            head :no_content
          else
            render json: ErrorSerializer.validation(@company.errors),
                   status: :unprocessable_entity
          end
        end

        private

        def set_company
          @company = Company.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          render json: ErrorSerializer.new(
            message: "Company not found",
            status: 404
          ).as_json, status: :not_found
        end

        def company_params
          params.require(:company).permit(
            :name, :business_name, :cif, :ccc, :street, :number, :door, :floor,
            :postal_code, :city, :province, :contact_email, :contact_phone_main,
            :contact_phone_secondary, :logo_url
          )
        end
      end
    end
  end
end
