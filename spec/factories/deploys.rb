# Generates fake deploy data we can use to test with
FactoryBot.define do
  factory :deploy, :class => Hubstats::Deploy do
    git_revision "3dis01"
    repo_id 101010
    deployed_at "2015-02-03 03:00:00 -0500"
    user_id 202020
  end

   factory :deploy_no_user, :class => Hubstats::Deploy do
    git_revision "3dis01"
    repo_id 101010
    deployed_at "2015-02-03 03:00:00 -0500"
    user_id nil
  end
end
