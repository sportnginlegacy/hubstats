FactoryGirl.define do
  factory :deploy, :class => Hubstats::Deploy do
    git_revision "3dis01"
    repo_id 101010
    deployed_at "2015-02-03 03:00:00 -0500"
    deployed_by "emmasax1"
  end

    factory :bad_deploy, :class => Hubstats::Deploy do
    git_revision "3dis01"
    repo_id nil
    deployed_at "2015-02-03 03:00:00 -0500"
    deployed_by "emmasax1"
  end
end
