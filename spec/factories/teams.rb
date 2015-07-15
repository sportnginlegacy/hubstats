# Generates fake team data we can use to test with
FactoryGirl.define do
  factory :team, :class => Hubstats::Team do
    name "Team One"
    hubstats true
  end

  factory :team_payload_hash, class:Hash do 
    id {Faker::Number.number(6).to_i}
    type "MembershipEvent"
    action "added"
    name "content-management"
    association :user, factory: :user_hash, strategy: :build
    initialize_with { attributes } 
  end 
end
