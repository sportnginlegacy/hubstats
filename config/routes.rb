Hubstats::Engine.routes.draw do
  root to: "repos#index"
  post "/handler" => "events#handler", :as => "handler"
  get "/users" => "users#index", :as => :users
  get "/user/:id" => "users#show", :as => :user

  get "/:repo" => "repos#show", :as => :repo
  scope "/:repo", :as => :repo do
    get '/pull_requests' => "pull_requests#index", :as => :pull_requests
    get '/pull_request/:id' => "pull_requests#show", :as => :pull_request
  end

end
