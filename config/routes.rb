Hubstats::Engine.routes.draw do
  root to: "splash#index"

  resources :splash
end
