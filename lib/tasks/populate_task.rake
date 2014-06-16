namespace :populate do

  desc "Pull members from Github saves in database"
  task :users, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args[:repo].nil?
    puts "Adding contributors to " + args[:repo]

    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    contributors = client.contribs(args[:repo])

    contributors.each do |contributor|
      cont = Hubstats::User.find_or_create_user(contributor)
    end
  end

  desc "Pull comments from Github saves in database"
  task :comments, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args[:repo].nil?
    puts "Adding comments to " + args[:repo]

    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    comments = client.pull_requests_comments(args[:repo])

    comments.each do |comment|
      comm = Hubstats::Comment.find_or_create_comment(comment)
    end
  end

  desc "Pull pull requests from Github saves in database"
  task :pulls, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args[:repo].nil?
    puts "Adding pulls to " + args[:repo]

    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    pulls = client.pulls(args[:repo], :state => "closed")

    pulls.each do |pull|
      pr = Hubstats::PullRequest.find_or_create_pull(pull)
    end
  end

  desc "Pull repos from Github save to database"
  task :all => :environment do
    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    get_repos.each do |repo|
      re = Hubstats::Repo.find_or_create_repo(repo)

      Rake::Task["app:populate:users"].execute({repo: "#{re.full_name}"})
      Rake::Task["app:populate:pulls"].execute({repo: "#{re.full_name}"})
      Rake::Task["app:populate:comments"].execute({repo: "#{re.full_name}"})
      
    end
  end

  def get_repos
    client = Hubstats::GithubAPI.client
    if OCTOCONF.has_key?(:org_name)
      repos = client.organization_repositories(OCTOCONF[:org_name])
    else 
      repos = []
      OCTOCONF[:repo_list].each do |repo|
        repos << client.repository(repo)
      end
    end
    repos
  end

end