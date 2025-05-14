Rails.application.routes.draw do
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Expose weather data per-country/zip code
  get "/:country/:code", to: "weather#show", as: :weather

  # Allow searching for an address on the homepage
  post "/", to: "addresses#lookup", as: :address_lookup

  # Show the address search form by default
  root "addresses#index"
end
