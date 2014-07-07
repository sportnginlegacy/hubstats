FactoryGirl.define do
  factory :user, :class => Hubstats::User do
    login { Faker::Internet.user_name }
    id {|n| "#{n}"}
    role "User"
  end

  factory :user_hash, class:Hash do
    login { Faker::Internet.user_name }
    id {|n| "#{n}"}
    type "User"

    initialize_with { attributes } 
  end

end