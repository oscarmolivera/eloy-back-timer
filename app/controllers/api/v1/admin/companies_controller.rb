module Api
  module V1
    module Admin
      class CompaniesController < Api::V1::BaseController
        before_action :authenticate_user!
        before_action :require_superadmin!

        def index
          @companies = Company.order(:created_at)
          render json: @companies
        end

        def show
          @company = Company.find(params[:id])
          render json: @company
        end

        def create
          @company = Company.new(company_params)
          if @company.save
            render json: @company, status: :created
          else
            render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          @company = Company.find(params[:id])
          if @company.update(company_params)
            render json: @company
          else
            render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def destroy
          @company = Company.find(params[:id])
          if @company.update(active: false)
            head :no_content
          else
            render json: { errors: @company.errors.full_messages }, status: :unprocessable_entity
          end
        end

        private

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
