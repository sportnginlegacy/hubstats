# Generates fake comment data we can use to test with
FactoryGirl.define do
  factory :comment, :class => Hubstats::Comment do
    user
    id {Faker::Number.number(6).to_i}
    body {Faker::Lorem.sentence}
  end

  factory :comment_hash, class:Hash do
    association :user, factory: :user_hash, strategy: :build
    id {Faker::Number.number(6).to_i}
    body {Faker::Lorem.sentence}
    initialize_with { attributes } 
  end

  factory :comment_payload_hash, class:Hash do 
    id {Faker::Number.number(6).to_i}
    type ["IssueCommentEvent", "CommitCommentEvent", "PullRequestReviewCommentEvent"].sample
    association :repository, factory: :repo_hash, strategy: :build
    association :pull_request, factory: :pull_request_hash, strategy: :build
    association :comment, factory: :comment_hash, strategy: :build
    initialize_with { attributes } 
  end 
end
