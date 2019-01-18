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
    initialize_with { attributes }
  end

  factory :repo_payload_hash, class:Hash do
    id {Faker::Number.number(6).to_i}
    type "RepositoryEvent"
    association :user, factory: :user_hash, strategy: :build
    association :repo, factory: :repo_hash, strategy: :build
    initialize_with { attributes }
  end
end
