Hubstats::Engine.routes.draw do
  root to: "splash#index"

 get "/:repo" => "repo#show", :as => :repo
end
