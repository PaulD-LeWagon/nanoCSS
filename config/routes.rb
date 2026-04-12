Rails.application.routes.draw do
  root "themes#index"
  
  get "/configure", to: "themes#show", as: :configure
  post "/themes/preview", to: "themes#preview", as: :theme_preview
  match "/themes/download", to: "themes#download", as: :theme_download, via: [:get, :post]
  get "/components", to: "components#index"

  # Defines the root path route ("/")
  # root "posts#index"
end
