# Generates fake team data we can use to test with
FactoryGirl.define do
  factory :team, :class => Hubstats::Team do
    name "Team One"
    description "An awesome team"
    hubstats true
  end
end
