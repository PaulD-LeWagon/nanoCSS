Rails.application.routes.draw do
  root "themes#index"
  
  get "/configure", to: "themes#show", as: :configure
  post "/themes/preview", to: "themes#preview", as: :theme_preview
  get "/themes/css", to: "themes#css", as: :theme_css
  match "/themes/download", to: "themes#download", as: :theme_download, via: [:get, :post]
  get "/components", to: "components#index"
  get "/components/test", to: "components#test_page", as: :components_test
  resources :fonts, only: [:index]

  # Defines the root path route ("/")
  # root "posts#index"
end
