Hubification::Engine.routes.draw do
  root to: "splash#index"

  resources :articles
end
