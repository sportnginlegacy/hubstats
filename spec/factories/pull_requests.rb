FactoryGirl.define do
  factory :pull_request, :class => Hubstats::PullRequest do
    user
    repo
    id {Faker::Number.number(6).to_i}
    number {|n| "#{n}".to_i}
  end

  factory :pull_request_hash, class:Hash do
    association :user, factory: :user_hash, strategy: :build
    association :repository, factory: :repo_hash, strategy: :build
    id {Faker::Number.number(6).to_i}
    number {|n| "#{n}".to_i}
    merged_by(:id => 202020)

    initialize_with { attributes } 
  end

  factory :pull_request_hash_no_merge, class:Hash do
    association :user, factory: :user_hash, strategy: :build
    association :repository, factory: :repo_hash, strategy: :build
    id {Faker::Number.number(6).to_i}
    number {|n| "#{n}".to_i}

    initialize_with { attributes } 
  end

  factory :pull_request_payload_hash, class:Hash do 
    id {Faker::Number.number(6).to_i}
    type "PullRequestEvent"
    association :repository, factory: :repo_hash, strategy: :build
    association :pull_request, factory: :pull_request_hash, strategy: :build
    merged_by(:id => 202020)

    initialize_with { attributes } 
  end 
end
