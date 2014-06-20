namespace :populate do

  desc "Pull members from Github saves in database"
  task :users, [:repo] => :environment do |t, args|
    args[:repo] ? (repo = args[:repo]) : (raise ArgumentError, "Must be called with repo argument. [:org/:repo]")
    puts "Adding contributors to " + repo

    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    contributors = client.contribs(args[:repo])

    contributors.each do |contributor|
      cont = Hubstats::User.find_or_create_user(contributor)
    end
  end

  desc "Pull comments from Github saves in database"
  task :comments, [:repo] => :environment do |t, args|
    args[:repo] ? (repo = args[:repo]) : (raise ArgumentError, "Must be called with repo argument. [:org/:repo]")
    repo = Hubstats::Repo.where(full_name: repo).first
    puts "Adding comments to " + repo.full_name

    client = Hubstats::GithubAPI.client({:auto_paginate => true})

    pull_comments = Hubstats::GithubAPI.all(["repos",repo.full_name].join('/'),"pulls/comments")
    pull_comments.each do |comment|
      comm = Hubstats::Comment.create_or_update(comment_setup(comment,repo.id,"PullRequest"))
    end

    issue_comments = client.issues_comments(repo.full_name,{sort: 'created', direction: 'desc'})
    issue_comments.each do |comment|
      comm = Hubstats::Comment.create_or_update(comment_setup(comment,repo.id,"Issue"))
    end

    commit_comments = client.list_commit_comments(repo.full_name)
    commit_comments.each do |comment|
      comm = Hubstats::Comment.create_or_update(comment_setup(comment,repo.id,"Commit"))
    end
  end

  desc "Pull pull requests from Github saves in database"
  task :pulls, [:repo] => :environment do |t, args|
    args[:repo] ? (repo = args[:repo]) : (raise ArgumentError, "Must be called with repo argument. [:org/:repo]")
    puts "Adding pulls to " + args[:repo]

    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    closed_pulls = client.pulls(repo, :state => "closed")
    pulls = closed_pulls.concat(client.pulls(repo, :state => "open"))

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
      eventsHandler.route(event[:payload],event[:type])
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

  def comment_setup(comment, repo_id, kind)
    comment[:repo_id] = repo_id
    comment[:pull_number] = get_pull_number(comment)
    comment[:kind] = kind
    return comment
  end

  def get_pull_number(comment)
    if comment[:pull_request]
      return comment[:pull_request][:number]
    elsif comment[:issue_url]
      return comment[:issue_url].split('/')[-1]
    elsif comment[:pull_request_url]
      return comment[:pull_request_url].split('/')[-1]
    else
      return nil
    end
  end

end