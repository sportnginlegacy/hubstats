namespace :populate do

  desc "Pull members from Github saves in database"
  task :users, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. ['repos/sportngin/:repo']" if args.repo.nil? 
    
    puts "Adding contributors to " + args.repo

    contributors = Hubstats::GithubAPI.all(args.repo, 'contributors')

    contributors.each do |contributor|
      cont = Hubstats::User.find_or_create_user(contributor)
    end
  end

  desc "Pull comments from Github saves in database"
  task :comments, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. [repos/sportngin/:repo]" if args.repo.nil?

    comments = Hubstats::GithubAPI.all(args.repo,'comments')

    comments.each do |comment|
      comm = Hubstats::Comment.find_or_create_comment(comment)
    end
  end

  desc "Pull pull requests from Github saves in database"
  task :pulls, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. [repos/sportngin/:repo]" if args.repo.nil?

    pulls = Hubstats::GithubAPI.all(args.repo,"pulls")

    pulls.each do |pull|
      pr = Hubstats::PullRequest.find_or_create_pull(pull)
    end
  end

  desc "Pull repos from Github save to database"
  task :all => :environment do
    client = Hubstats::GithubAPI.client({:auto_paginate => true})
    get_repos.each do |repo|
      re = Hubstats::Repo.find_or_create_repo(repo)

      contributors = client.contribs(repo.full_name)
      contributors.each do |contributor|
        user = Hubstats::User.find_or_create_user(contributor)
      end

      pull_requests = client.pulls(repo.full_name, :state => "closed")
      pull_requests.each do |pull_request|
        pull = Hubstats::PullRequest.find_or_create_pull(pull_request)
      end

      comments = client.pull_requests_comments(repo.full_name)
      comments.each do |comment|
        comm = Hubstats::Comment.find_or_create_comment(comment)
      end
      
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