class ApiDocsController < ApplicationController
  before_action :verify_api_key

  def show
    render html: docs_html.html_safe, layout: false
  end

  def spec
    render json: openapi_spec
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

  def openapi_spec
    {
      openapi: "3.0.3",
      info: {
        title: "EloyTimer API",
        version: "1.0.0",
        description: "Backend API for EloyTimer — employee shift management for the Spanish hospitality industry.",
        contact: {
          name: "EloyTimer Team",
          url: "https://github.com/oscarmolivera/eloy-back-timer"
        }
      },
      servers: [
        {
          url: "https://eloy-back-timer-api-server.onrender.com",
          description: "Production"
        },
        {
          url: "http://localhost:3000",
          description: "Local development"
        }
      ],
      components: {
        securitySchemes: {
          ApiKeyAuth: {
            type: "apiKey",
            in: "header",
            name: "X-API-Key"
          },
          BearerAuth: {
            type: "http",
            scheme: "bearer",
            bearerFormat: "JWT"
          }
        },
        schemas: {
          Error: {
            type: "object",
            properties: {
              error: { type: "string", example: "Unauthorized" },
              message: { type: "string", example: "Invalid or missing API key" }
            }
          },
          Company: {
            type: "object",
            properties: {
              id:         { type: "integer", example: 1 },
              name:       { type: "string",  example: "Restaurant Pepe" },
              slug:       { type: "string",  example: "restaurant-pepe" },
              logo_url:   { type: "string",  example: "https://example.com/logo.png" },
              active:     { type: "boolean", example: true },
              created_at: { type: "string",  format: "date-time" }
            }
          },
          User: {
            type: "object",
            properties: {
              id:    { type: "integer", example: 1 },
              email: { type: "string",  example: "admin@eloytimer.com" },
              role:  { type: "string",  example: "superadmin", enum: ["superadmin"] }
            }
          }
        }
      },
      security: [{ ApiKeyAuth: [] }],
      tags: [
        { name: "Infrastructure", description: "Liveness and health checks" },
        { name: "Authentication",  description: "Login, token refresh and logout" },
        { name: "Admin — Companies", description: "Superadmin company management" },
        { name: "Public",          description: "Public-facing endpoints, no auth required" }
      ],
      paths: openapi_paths
    }
  end

  def openapi_paths # rubocop:disable Metrics/MethodLength
    {
      "/up": {
        get: {
          tags: ["Infrastructure"],
          summary: "Rails liveness check",
          description: "Used by Render, Docker and uptime monitors. Returns 200 if Rails boots without exceptions.",
          security: [],
          responses: {
            "200": { description: "App is alive" },
            "500": { description: "App failed to boot" }
          }
        }
      },
      "/api/v1/health": {
        get: {
          tags: ["Infrastructure"],
          summary: "API health check",
          description: "Returns API version, environment, timestamp and live database connectivity. First call the frontend makes on boot.",
          responses: {
            "200": {
              description: "API and database healthy",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      status:      { type: "string", example: "ok" },
                      version:     { type: "string", example: "1.0.0" },
                      environment: { type: "string", example: "production" },
                      timestamp:   { type: "string", format: "date-time" },
                      database:    { type: "string", example: "connected" }
                    }
                  }
                }
              }
            },
            "401": { description: "Missing or invalid API key", content: { "application/json": { schema: { :"$ref" => "#/components/schemas/Error" } } } }
          }
        }
      },
      "/api/v1/auth/login": {
        post: {
          tags: ["Authentication"],
          summary: "Login — returns JWT tokens",
          description: "Authenticates a user. Returns a short-lived access token (15 min) and a refresh token (7 days).",
          security: [],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  required: ["email", "password"],
                  properties: {
                    email:    { type: "string", format: "email", example: "admin@eloytimer.com" },
                    password: { type: "string", format: "password", example: "secret" }
                  }
                }
              }
            }
          },
          responses: {
            "200": {
              description: "Login successful",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      access_token:  { type: "string" },
                      refresh_token: { type: "string" },
                      user: { :"$ref" => "#/components/schemas/User" }
                    }
                  }
                }
              }
            },
            "401": { description: "Wrong password or email not found" },
            "403": { description: "User account is inactive" }
          }
        }
      },
      "/api/v1/auth/refresh": {
        post: {
          tags: ["Authentication"],
          summary: "Refresh access token",
          description: "Issues a new access token using a valid refresh token.",
          security: [],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  required: ["refresh_token"],
                  properties: {
                    refresh_token: { type: "string" }
                  }
                }
              }
            }
          },
          responses: {
            "200": {
              description: "New access token issued",
              content: { "application/json": { schema: { type: "object", properties: { access_token: { type: "string" } } } } }
            },
            "401": { description: "Refresh token expired or invalid" }
          }
        }
      },
      "/api/v1/auth/logout": {
        delete: {
          tags: ["Authentication"],
          summary: "Logout — invalidate session",
          description: "Invalidates the refresh token server-side.",
          security: [{ ApiKeyAuth: [] }, { BearerAuth: [] }],
          responses: {
            "204": { description: "Session ended" },
            "401": { description: "Invalid or missing token" }
          }
        }
      },
      "/api/v1/admin/companies": {
        get: {
          tags: ["Admin — Companies"],
          summary: "List all companies",
          description: "Paginated list of all companies. Superadmin only.",
          security: [{ ApiKeyAuth: [] }, { BearerAuth: [] }],
          responses: {
            "200": {
              description: "Paginated company list",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      companies: { type: "array", items: { :"$ref" => "#/components/schemas/Company" } },
                      meta: {
                        type: "object",
                        properties: {
                          total:    { type: "integer" },
                          page:     { type: "integer" },
                          per_page: { type: "integer" }
                        }
                      }
                    }
                  }
                }
              }
            },
            "401": { description: "Missing or invalid token" },
            "403": { description: "User is not a superadmin" }
          }
        },
        post: {
          tags: ["Admin — Companies"],
          summary: "Create a company",
          description: "Creates a new company. Slug auto-generated from name if not provided.",
          security: [{ ApiKeyAuth: [] }, { BearerAuth: [] }],
          requestBody: {
            required: true,
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  required: ["company"],
                  properties: {
                    company: {
                      type: "object",
                      required: ["name"],
                      properties: {
                        name:     { type: "string", example: "Restaurant Pepe" },
                        slug:     { type: "string", example: "restaurant-pepe" },
                        logo_url: { type: "string", example: "https://example.com/logo.png" }
                      }
                    }
                  }
                }
              }
            }
          },
          responses: {
            "201": { description: "Company created", content: { "application/json": { schema: { :"$ref" => "#/components/schemas/Company" } } } },
            "401": { description: "Missing or invalid token" },
            "403": { description: "User is not a superadmin" },
            "422": { description: "Validation errors" }
          }
        }
      },
      "/api/v1/admin/companies/{id}": {
        get: {
          tags: ["Admin — Companies"],
          summary: "Get a company",
          security: [{ ApiKeyAuth: [] }, { BearerAuth: [] }],
          parameters: [{ name: "id", in: "path", required: true, schema: { type: "integer" } }],
          responses: {
            "200": { description: "Company detail", content: { "application/json": { schema: { :"$ref" => "#/components/schemas/Company" } } } },
            "404": { description: "Company not found" }
          }
        },
        patch: {
          tags: ["Admin — Companies"],
          summary: "Update a company",
          description: "Partial updates supported — only send fields you want to change.",
          security: [{ ApiKeyAuth: [] }, { BearerAuth: [] }],
          parameters: [{ name: "id", in: "path", required: true, schema: { type: "integer" } }],
          requestBody: {
            content: {
              "application/json": {
                schema: {
                  type: "object",
                  properties: {
                    company: {
                      type: "object",
                      properties: {
                        name:     { type: "string" },
                        logo_url: { type: "string" },
                        active:   { type: "boolean" }
                      }
                    }
                  }
                }
              }
            }
          },
          responses: {
            "200": { description: "Company updated", content: { "application/json": { schema: { :"$ref" => "#/components/schemas/Company" } } } },
            "404": { description: "Company not found" },
            "422": { description: "Validation errors" }
          }
        },
        delete: {
          tags: ["Admin — Companies"],
          summary: "Deactivate a company",
          description: "Sets active: false. Never hard-deletes. All data preserved.",
          security: [{ ApiKeyAuth: [] }, { BearerAuth: [] }],
          parameters: [{ name: "id", in: "path", required: true, schema: { type: "integer" } }],
          responses: {
            "200": { description: "Company deactivated" },
            "404": { description: "Company not found" }
          }
        }
      },
      "/api/v1/companies": {
        get: {
          tags: ["Public"],
          summary: "List active companies",
          description: "Returns all active companies. Used by the frontend landing page. No JWT required.",
          security: [],
          responses: {
            "200": {
              description: "Active companies",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      companies: {
                        type: "array",
                        items: {
                          type: "object",
                          properties: {
                            name:     { type: "string" },
                            slug:     { type: "string" },
                            logo_url: { type: "string" }
                          }
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      },
      "/api/v1/companies/{slug}": {
        get: {
          tags: ["Public"],
          summary: "Get company public page",
          description: "Public-facing company info by slug. Used for individual company landing pages.",
          security: [],
          parameters: [{ name: "slug", in: "path", required: true, schema: { type: "string" }, example: "restaurant-pepe" }],
          responses: {
            "200": {
              description: "Company public profile",
              content: {
                "application/json": {
                  schema: {
                    type: "object",
                    properties: {
                      name:          { type: "string" },
                      slug:          { type: "string" },
                      logo_url:      { type: "string" },
                      tagline:       { type: "string" },
                      industry_type: { type: "string" }
                    }
                  }
                }
              }
            },
            "404": { description: "Company not found or inactive" }
          }
        }
      }
    }
  end

  def docs_html
    spec_url = "/api-docs/spec.json?api_key=#{Rails.application.credentials.dig(:api, :secret_key)}"

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