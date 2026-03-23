module Api
  module V1
    class BaseController < ApplicationController
      include Authenticatable

      before_action :verify_api_key

      rescue_from Authenticatable::AuthenticationError, with: :render_unauthorized
      rescue_from Authenticatable::AuthorizationError,  with: :render_forbidden

      private

      def verify_api_key
        provided_key = request.headers["X-API-Key"]
                               .presence || params[:api_key].presence
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

      def render_unauthorized(exception)
        render json: {
          error: "Unauthorized",
          message: exception.message
        }, status: :unauthorized
      end

      def render_forbidden(exception)
        render json: {
          error: "Forbidden",
          message: exception.message
        }, status: :forbidden
      end
    end
  end
end
