module Api
  module V1
    class BaseController < ApplicationController
      before_action :verify_api_key

      private

      def verify_api_key
        provided_key = request.headers["X-API-Key"]
        expected_key = Rails.application.credentials.dig(:api, :secret_key)

        return if ActiveSupport::SecurityUtils.secure_compare(
          provided_key.to_s,
          expected_key.to_s
        )

        render json: {
          error: "Unauthorized",
          message: "Invalid or missing API key"
        }, status: :unauthorized
      end
    end
  end
end
