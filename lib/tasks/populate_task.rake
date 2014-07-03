namespace :hubstats do 
  namespace :populate do

    desc "Pull members from Github saves in database"
    task :users, [:repo] => :environment do |t, args|
      repo = repo_checker(args[:repo])
      puts "Adding contributors to " + repo.full_name

      Hubstats::GithubAPI.client({:auto_paginate => true}).contribs(repo.full_name).each do |contributor|
        cont = Hubstats::User.create_or_update(contributor)
      end
    end

    desc "Pull comments from Github saves in database"
    task :comments, [:repo] => :environment do |t, args|
      repo = repo_checker(args[:repo])
      puts "Adding comments to " + repo.full_name

      pull_comments = Hubstats::GithubAPI.inline(repo.full_name,'pulls/comments')
      issue_comments = Hubstats::GithubAPI.inline(repo.full_name,'issues/comments')
      commit_comments = Hubstats::GithubAPI.inline(repo.full_name,'comments')
    end

    desc "Pull pull requests from Github saves in database"
    task :pulls, [:repo] => :environment do |t, args|
      repo = repo_checker(args[:repo])
      puts "Adding pulls to " + repo.full_name
      
      pull_requests = Hubstats::GithubAPI.inline(repo.full_name,'pulls', :state => "all")
    end

    desc "Pull labels from Github saves in database"
    task :labels, [:repo] => :environment do |t, args|
      repo = repo_checker(args[:repo])
      puts "Adding labels for to " + repo.full_name

      Hubstats::GithubAPI.client({:auto_paginate => true}).labels(repo.full_name).each do |label|

        label_hash = label.to_h if label.respond_to? :to_h
        label_data = label_hash.slice(*Hubstats::Label.column_names.map(&:to_sym))
        label = Hubstats::Label.where(:name => label_data[:name]).first_or_create(label_data)
      end
    end

    desc "Pull repos from Github save to database"
    task :all => :environment do
      get_repos.each do |repo|
        repo = Hubstats::Repo.create_or_update(repo)
        Hubstats::GithubAPI.create_hook(repo)
        
        Rake::Task["hubstats:populate:users"].execute({repo: repo})
        Rake::Task["hubstats:populate:pulls"].execute({repo: repo})
        Rake::Task["hubstats:populate:comments"].execute({repo: repo})
      end
      puts "Finished with initial population, grabing extra info for pull requests"
      Rake::Task["hubstats:populate:update_labels"].execute
      Rake::Task["hubstats:populate:update_pulls"].execute
    end

    desc "indivdually gets and updates pull requests"
    task :update_pulls => :environment do
      Hubstats::GithubAPI.update_pulls
    end

    desc "sets labels for pull_requests"
    task :update_labels => :environment do
      Hubstats::GithubAPI.update_labels
    end

    def repo_checker(args)
      raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args.nil?
      if args.is_a? String
        return Hubstats::Repo.where(full_name: args).first
      else 
        return args
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