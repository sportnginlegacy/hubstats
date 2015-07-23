# Generates fake user data we can use to test with
FactoryGirl.define do
  factory :user, :class => Hubstats::User do
    login { Faker::Internet.user_name }
    id {|n| "#{n}".to_i}
    role "User"
    created_at '2015-05-30'
  end

  factory :user_hash, class:Hash do
    login { Faker::Internet.user_name }
    id {|n| "#{n}".to_i}
    role "User"
    created_at '2015-05-30'

    initialize_with { attributes } 
  end
end
