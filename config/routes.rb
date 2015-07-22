# Draw all of the routes that will be used in Hubstats
Hubstats::Engine.routes.draw do
  post "/handler" => "events#handler", :as => :handler
  root to: "pull_requests#index" # sets default root to be the pulls page
  get "/pulls" => "pull_requests#index", :as => :pulls # routes to list of pulls
  resources :deploys, :only => [:create, :index, :show] # routes to index, show, and to create method
  resources :teams, :only => [:index, :show]
  get "/users" => "users#index", :as => :users # routes to list of users
  get "/user/:id" => "users#show", :as => :user # routes to specific user's contributions
  get "/repos" => "repos#index", :as => :repos # routes to the list of repos
  get "/:repo" => "repos#show", :as => :repo # routes to specific repo's stats
  scope "/:repo", :as => :repo do
    get '/pull/:id' => "pull_requests#show", :as => :pull # routes to the specific repo's pull id
  end
end
