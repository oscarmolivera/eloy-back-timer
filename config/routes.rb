Rails.application.routes.draw do
  # Used by Render, Docker and uptime monitors — do not remove
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get  "health", to: "health#show"

      namespace :auth do
        post   "login",   to: "auth#login"
        post   "refresh", to: "auth#refresh"
        delete "logout",  to: "auth#logout"
      end

      namespace :admin do
        resources :companies, except: [:new, :edit]
      end
    end
  end
end
