Rails.application.routes.draw do
  # Used by Render, Docker and uptime monitors — do not remove
  get "up" => "rails/health#show", as: :rails_health_check

  namespace :api do
    namespace :v1 do
      get "health", to: "health#show"
    end
  end
end