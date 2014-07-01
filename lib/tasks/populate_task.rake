namespace :hubstats do 
  namespace :populate do

    desc "Pull members from Github saves in database"
    task :users, [:repo] => :environment do |t, args|
      raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args[:repo].nil?
      repo = args[:repo]
      puts "Adding contributors to " + repo

      Hubstats::GithubAPI.client({:auto_paginate => true}).contribs(args[:repo]).each do |contributor|
        cont = Hubstats::User.create_or_update(contributor)
      end
    end

    desc "Pull comments from Github saves in database"
    task :comments, [:repo] => :environment do |t, args|
      raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args[:repo].nil?
      repo = Hubstats::Repo.where(full_name: args[:repo]).first
      puts "Adding comments to " + repo.full_name

      pull_comments = Hubstats::GithubAPI.inline(repo.full_name,'pulls/comments')
      issue_comments = Hubstats::GithubAPI.inline(repo.full_name,'issues/comments')
      commit_comments = Hubstats::GithubAPI.inline(repo.full_name,'comments')
    end

    desc "Pull pull requests from Github saves in database"
    task :pulls, [:repo] => :environment do |t, args|
      raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args[:repo].nil?
      repo = Hubstats::Repo.where(full_name: args[:repo]).first
      puts "Adding pulls to " + repo.full_name
      
      pull_requests = Hubstats::GithubAPI.inline(repo.full_name,'pulls', :state => "all")
    end

    desc "Pull repos from Github save to database"
    task :all => :environment do
      client = Hubstats::GithubAPI.client({:auto_paginate => true})
      get_repos.each do |repo|
        re = Hubstats::Repo.create_or_update(repo)

        Rake::Task["hubstats:populate:users"].execute({repo: "#{re.full_name}"})
        Rake::Task["hubstats:populate:pulls"].execute({repo: "#{re.full_name}"})
        Rake::Task["hubstats:populate:comments"].execute({repo: "#{re.full_name}"})
      end
      puts "Finished with initial population, grabing extra info for pull requests"
      Rake::Task["hubstats:populate:update"].execute()
    end

    desc "indivdually gets and updates pull requests"
    task :update => :environment do
      grab_size = 10
      while Hubstats::PullRequest.where(deletions: nil).where(additions: nil).count() > 0
        client = Hubstats::GithubAPI.client
        puts client.rate_limit.remaining
        incomplete = Hubstats::PullRequest.where(deletions: nil).where(additions: nil).limit(grab_size)

        incomplete.each do |pull|
          repo = Hubstats::Repo.where(id: pull.repo_id).first
          pr = client.pull_request(repo.full_name, pull.number)
          Hubstats::PullRequest.create_or_update(pull_setup(pr))
        end

        Hubstats::GithubAPI.wait_limit(grab_size,client.rate_limit)
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
end