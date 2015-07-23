# Generates fake repo data we can use to test with
FactoryGirl.define do
  factory :repo, :class => Hubstats::Repo do
    id 101010
    name "hubstats"
    full_name "hub/hubstats"
    created_at '2015-05-30'
  end

  factory :repo_hash, class:Hash do
    id 101010
    name "Hubstats"
    full_name "hub/hubstats"
    created_at '2015-05-30'

    initialize_with { attributes } 
  end
end
