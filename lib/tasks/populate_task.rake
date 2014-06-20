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

    pull_comments = Hubstats::GithubAPI.all(["repos",args[:repo]].join('/'),"pulls/comments")

    puts "length",pull_comments.length
    pull_comments.each do |comment|
      puts comment.inspect
      comm = Hubstats::Comment.find_or_create_comment(comment)
    end

    issue_comments = client.issues_comments(args[:repo],{sort: 'created', direction: 'desc'})
    issue_comments.each do |comment|
      comm = Hubstats::Comment.find_or_create_issue_comment(comment,args[:repo])
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

  ## THIS IS ONLY FOR TESTING DELETE WHEN FINISHED WITH HANDLER
  desc "Pull all events from hubstats"
  task :events => :environment do |t,args|
    eventsHandler = Hubstats::EventsHandler.new()
    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    events = client.repository_events('sportngin/hubstats')

    events.each do |event|
      eventsHandler.route(event)
    end
    puts eventsHandler.pulls
    puts eventsHandler.other
  end


  desc "Pull repos from Github save to database"
  task :all => :environment do
    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    get_repos.each do |repo|
      re = Hubstats::Repo.find_or_create_repo(repo)

      Rake::Task["app:populate:users"].execute({repo: "#{re.full_name}"})
      # Rake::Task["app:populate:pulls"].execute({repo: "#{re.full_name}"})
      # Rake::Task["app:populate:comments"].execute({repo: "#{re.full_name}"})
      
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