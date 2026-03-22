# EloyTimer API

A modern REST API for employee shift management in the Spanish hospitality industry, built with Ruby on Rails 8.0.

## Overview

EloyTimer API provides comprehensive endpoints for managing company data, user authentication, and shift management. The API features automatic OpenAPI documentation generation, JWT token authentication, and API key support for integration endpoints.

## Table of Contents

- [Requirements](#requirements)
- [Setup](#setup)
- [Configuration](#configuration)
- [Database](#database)
- [Running the Application](#running-the-application)
- [Testing](#testing)
- [API Documentation](#api-documentation)
- [Services](#services)
- [Deployment](#deployment)

## Requirements

### Ruby Version
- Ruby 3.3.3 or later

### System Dependencies
- PostgreSQL 14+
- Redis (for caching and job queue)
- Node.js 18+ (for asset pipeline)

### Encryption & Security
- Credentials managed via Rails encrypted credentials (`config/credentials.yml.enc`)
- Environment-specific encrypted credentials in `config/credentials/`

## Setup

### 1. Clone and Install Dependencies

```bash
git clone <repository-url>
cd eloy-back-timer
bundle install
```

### 2. Configure Environment

Copy the example environment file (if available) or create your own:

```bash
cp .env.example .env  # (if available)
```

Edit `.env` with your environment-specific settings:
```bash
DATABASE_URL=postgres://localhost/eloy_timer_development
REDIS_URL=redis://localhost:6379/0
```

### 3. Setup Encrypted Credentials

Rails uses encrypted credentials for secrets. To edit:

```bash
# Development environment
EDITOR=nano rails credentials:edit

# Test environment
EDITOR=nano rails credentials:edit --environment test

# Production environment
EDITOR=nano rails credentials:edit --environment production
```

Required credentials structure:
```yaml
api:
  secret_key: your-secret-api-key-here
```

## Configuration

### Environment Variables

- `RAILS_ENV` - Environment (development, test, production)
- `DATABASE_URL` - PostgreSQL connection string
- `REDIS_URL` - Redis connection string
- `OPENAPI` - Set to any value to generate OpenAPI specs (e.g., `OPENAPI=1`)

### Rails Configuration

- **CORS**: Configured in `config/initializers/cors.rb`
- **Cache**: File-based for development, Redis for production
- **Job Queue**: `solid_queue` for background jobs (configured in `config/queue.yml`)

## Database

### Database Creation

```bash
rails db:create
```

### Database Migrations

```bash
rails db:migrate
```

### Database Seeding

Populate development and production data:

```bash
# Development seeds
rails db:seed:development

# Production seeds (when appropriate)
rails db:seed:production
```

### Database Reset

```bash
rails db:reset  # Drops, recreates, and seeds the database
```

## Running the Application

### Development Server

Start the Rails development server:

```bash
bin/dev  # Uses Procfile.dev for concurrent processes
```

Or manually:

```bash
rails s -p 3000
```

The API will be available at `http://localhost:3000`

### Production Build

```bash
RAILS_ENV=production rails assets:precompile
RAILS_ENV=production rails server -p 3000
```

## Testing

### Run Full Test Suite

```bash
bundle exec rspec
```

### Run Specific Test File

```bash
bundle exec rspec spec/requests/api/v1/auth_spec.rb
```

### Run Tests with Coverage

```bash
bundle exec rspec --format documentation --color
```

### Run Linters & Security Checks

```bash
# RuboCop (code style)
bundle exec rubocop

# Brakeman (security analysis)
bundle exec brakeman

# Bundler Audit (dependency vulnerabilities)
bundle exec bundler-audit --update
```

## API Documentation

### Automatic OpenAPI Generation

The API uses RSpec OpenAPI to automatically generate OpenAPI 3.0 specifications from your tests.

#### Generating Documentation

Run the test suite with the `OPENAPI` environment variable set:

```bash
OPENAPI=1 bundle exec rspec
```

This generates `doc/openapi.yaml` with complete API documentation.

#### Viewing Documentation

Once generated, you can view the API documentation through:

1. **Swagger UI** (if configured):
   - Visit `/api/docs` (when available)

2. **Redoc** (ReDoc for better UX):
   - Visit `/api/redoc` (when available)

3. **Local tools**:
   - Upload `doc/openapi.yaml` to [Swagger UI Editor](https://editor.swagger.io/)
   - Or use [Redoc CLI](https://redoc.ly/)

#### API Endpoints Structure

All endpoints follow this structure:
- **Tags**: Group endpoints by feature (Health, Auth, Admin::Companies)
- **Security**: Define authentication schemes (Bearer JWT, API Key)
- **Summaries**: Clear descriptions of each endpoint
- **Examples**: Request/response examples in the YAML spec

### Security Schemes

#### Bearer Token (JWT)
- Header: `Authorization: Bearer <jwt_token>`
- Used for authenticated user endpoints

#### API Key
- Header: `X-API-Key: <api_key>`
- Used for documentation access and public endpoints

### OpenAPI Metadata Configuration

Endpoint metadata is centralized in `spec/support/openapi_metadata.yaml`:

```yaml
health:
  summary: 'Check API health and database status'
  tags: ['Health']
  security: [{ 'ApiKeyAuth': [] }]

auth_login:
  summary: 'Log in and obtain JWT access and refresh tokens'
  tags: ['Auth']
  security: [{ 'ApiKeyAuth': [] }]
```

To add new endpoints, update `spec/support/openapi_metadata.yaml` and reference it in your spec files:

```ruby
describe "GET /api/v1/resource", openapi: OPENAPI_METADATA[:resource_index] do
  # tests...
end
```

## Services

### Background Jobs

Jobs are configured in `config/queue.yml` and run using `solid_queue`:

```bash
# Start job worker in development
bundle exec rails jobs:work

# In production, use:
bin/jobs start
```

### Cache

- **Development**: File-based cache (`tmp/cache/`)
- **Production**: Redis-backed cache

Cache configuration: `config/cache.yml`

### Database Caching

Separate `cache_schema.rb` for cache-specific tables (if needed).

## Deployment

### Containerized Deployment

The application includes Docker support:

```bash
# Build Docker image
docker build -t eloy-timer-api .

# Run container
docker run -p 3000:3000 eloy-timer-api
```

### Render.com Deployment

Configuration defined in `render.yaml`:

```bash
# Deploy to Render
# (Follow Render documentation for authentication and setup)
```

### Pre-deployment Checklist

- [ ] All tests passing: `bundle exec rspec`
- [ ] No security vulnerabilities: `bundle exec brakeman`
- [ ] Code style checked: `bundle exec rubocop`
- [ ] Credentials configured for target environment
- [ ] Database migrations ready

### Deployment Commands

```bash
# Production environment setup
RAILS_ENV=production bundle install --without development test
RAILS_ENV=production rails db:migrate
RAILS_ENV=production rails assets:precompile
```

## Project Structure

```
.
├── app/
│   ├── controllers/       # API controllers
│   │   ├── api/          # API-versioned controllers
│   │   │   └── v1/       # Version 1 endpoints
│   │   │       ├── auth_controller.rb
│   │   │       ├── health_controller.rb
│   │   │       └── admin/
│   │   └── api_docs_controller.rb
│   ├── models/           # Database models
│   ├── services/         # Business logic services
│   └── jobs/             # Background jobs
├── config/
│   ├── credentials/      # Encrypted environment secrets
│   ├── environments/     # Environment-specific config
│   ├── initializers/     # Rails initializers
│   └── routes.rb         # API routes
├── db/
│   ├── migrate/          # Database migrations
│   ├── seeds/            # Database seeds
│   └── schema.rb         # Current schema snapshot
├── doc/
│   └── openapi.yaml      # Generated OpenAPI spec
├── spec/
│   ├── requests/         # Request/integration specs
│   ├── models/           # Model unit tests
│   ├── services/         # Service specs
│   ├── support/          # RSpec helpers & configuration
│   │   └── openapi_metadata.yaml  # OpenAPI endpoint metadata
│   └── factories/        # Test data factories
└── README.md            # This file
```

## Contributing

1. Create a feature branch: `git checkout -b feature/my-feature`
2. Make changes and write tests
3. Run test suite: `bundle exec rspec`
4. Generate updated docs: `OPENAPI=1 bundle exec rspec`
5. Commit changes: `git commit -am 'feat: add my feature'`
6. Push to branch: `git push origin feature/my-feature`
7. Create Pull Request

## License

[License Information]

## Support

For issues or questions, please contact the development team or open an issue in the repository.
