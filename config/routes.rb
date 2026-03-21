Rails.application.routes.draw do
  # Used by Render, Docker and uptime monitors — do not remove
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"

      # Auth routes (fixed — no nested module)
      post   "auth/login",   to: "auth#login"
      post   "auth/refresh", to: "auth#refresh"
      delete "auth/logout",  to: "auth#logout"

      namespace :admin do
        resources :companies, except: [ :new, :edit ]
      end
    end
  end

  # API Docs routes (fixed — no nested module)
  scope "/api-docs" do
    get "/",         to: "api_docs#show",  as: :api_docs
    get "/spec.json", to: "api_docs#spec",  as: :api_docs_spec
  end
end
