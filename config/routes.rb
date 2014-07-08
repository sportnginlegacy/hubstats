Hubstats::Engine.routes.draw do
  root to: "repos#dashboard"

  post "/handler" => "events#handler", :as => "handler"
  get "/pulls" => "pull_requests#index", :as => :pulls
  get "/users" => "users#index", :as => :users
  get "/repos" => "repos#index", :as => :users
  get "/user/:id" => "users#show", :as => :user

  get "/:repo" => "repos#show", :as => :repo
  scope "/:repo", :as => :repo do
    get '/pulls' => "pull_requests#repo_index", :as => :pulls
    get '/pull/:id' => "pull_requests#show", :as => :pull
  end

end
