# Generates fake team data we can use to test with
FactoryGirl.define do
  factory :team, :class => Hubstats::Team do
    name "Team One"
    hubstats true
  end

  factory :team_false, :class => Hubstats::Team do
    name "Team One"
    hubstats false
  end

  factory :team_hash, class:Hash do
    association :user, factory: :user_hash, strategy: :build
    id {Faker::Number.number(6).to_i}
    name "Team One"
    hubstats true
    action "added"
    initialize_with { attributes }
  end

  factory :team_payload_hash, class:Hash do
    id {Faker::Number.number(6).to_i}
    type "MembershipEvent"
    association :user, factory: :user_hash, strategy: :build
    association :team, factory: :team_hash, strategy: :build
    initialize_with { attributes }
  end
end
