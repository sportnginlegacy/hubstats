Hubstats::Engine.routes.draw do
  root to: "pull_requests#index"

  post "/handler" => "events#handler", :as => :handler
  post "/deploy" => "deploys#create"
  get "/metrics" => "repos#dashboard", :as => :metrics 
  get "/pulls" => "pull_requests#index", :as => :pulls
  get "/deploys" => "deploys#index", :as => :deploys
  get "/users" => "users#index", :as => :users
  get "/repos" => "repos#dashboard", :as => :repos
  get "/user/:id" => "users#show", :as => :user
  get "/:repo" => "repos#show", :as => :repo
  scope "/:repo", :as => :repo do
    get '/pull/:id' => "pull_requests#show", :as => :pull
  end

end
