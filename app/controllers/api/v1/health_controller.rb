module Api
  module V1
    class HealthController < ApplicationController
      def show
        render json: {
          status: "ok",
          version: "1.0.0",
          environment: Rails.env,
          timestamp: Time.current.iso8601,
          database: database_reachable? ? "connected" : "unreachable"
        }, status: :ok
      end

      private

      def database_reachable?
        ActiveRecord::Base.connection.execute("SELECT 1")
        true
      rescue StandardError
        false
      end
    end
  end
end