Hubstats::Engine.routes.draw do
  root to: "pull_requests#index" #sets default root to be the pulls page
  post "/handler" => "events#handler", :as => :handler
  resources :deploys, :only => [:create, :index, :show] #routes to index, show, and to create method
  get "/metrics" => "repos#dashboard", :as => :metrics #routes to list of repos and stats
  get "/pulls" => "pull_requests#index", :as => :pulls #routes to list of pulls
  get "/users" => "users#index", :as => :users #routes to list of users
  get "/user/:id" => "users#show", :as => :user #routes to specific user's contributions
  get "/repos" => "repos#index", :as => :repos #route is for the repo filter on the pull request and deploys page
  get "/:repo" => "repos#show", :as => :repo #routes to specific repo's stats
  scope "/:repo", :as => :repo do
    get '/pull/:id' => "pull_requests#show", :as => :pull
  end
end
