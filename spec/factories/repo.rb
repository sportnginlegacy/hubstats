FactoryGirl.define do
  factory :repo, :class => Hubstats::Repo do
    id 101010
    name "hubstats"
    full_name "hub/hubstats"
  end

  factory :repo_hash, class:Hash do
    id 101010
    name "Hubstats"
    full_name "hub/hubstats"

    initialize_with { attributes } 
  end

end