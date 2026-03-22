class ApiDocsController < ApplicationController
  before_action :verify_api_key

  def show
    render html: docs_html.html_safe, layout: false
  end

  def spec
    spec_path = Rails.root.join("doc", "openapi.yaml")
    send_file spec_path,
              type: "application/yaml",
              disposition: "inline"
  end

  private

  def verify_api_key
    provided_key = request.headers["X-API-Key"].presence || params[:api_key].presence
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

  def docs_html
    spec_url = "/api-docs/spec?api_key=#{Rails.application.credentials.dig(:api, :secret_key)}"

    <<~HTML
      <!DOCTYPE html>
      <html>
        <head>
          <title>EloyTimer API Docs</title>
          <meta charset="utf-8"/>
          <meta name="viewport" content="width=device-width, initial-scale=1">
          <link href="https://fonts.googleapis.com/css?family=Montserrat:300,400,700|Roboto:300,400,700" rel="stylesheet">
          <style>
            body { margin: 0; padding: 0; }
          </style>
        </head>
        <body>
          <redoc spec-url="#{spec_url}"
                hide-download-button
                no-auto-auth
                theme='{
                  "colors": {
                    "primary": { "main": "#185FA5" }
                  },
                  "typography": {
                    "fontSize": "15px",
                    "fontFamily": "Roboto, sans-serif",
                    "headings": { "fontFamily": "Montserrat, sans-serif", "fontWeight": "700" }
                  },
                  "sidebar": {
                    "backgroundColor": "#0a0f1e",
                    "textColor": "#cbd5e1"
                  }
                }'>
          </redoc>
          <script src="https://cdn.jsdelivr.net/npm/redoc@latest/bundles/redoc.standalone.js"></script>
        </body>
      </html>
    HTML
  end
end
