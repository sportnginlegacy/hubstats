# A variety of commands that can be used to populate the database information
namespace :hubstats do 
  namespace :populate do

    desc "Pull repos from Github saves in database"
    task :setup_repos => :environment do
      Hubstats::GithubAPI.get_repos.each do |repo|
        Rake::Task["hubstats:populate:setup_repo"].execute({repo: repo})
      end
      puts "Finished with initial population, grabing extra info about pull requests"
      Rake::Task["hubstats:populate:update_pulls"].execute
    end

    desc "Updates which repos hubstats tracks" 
    task :update_repos => :environment do
      Hubstats::GithubAPI.get_repos.each do |repo|
        unless Hubstats::Repo.where(full_name: repo.full_name).first
          Rake::Task["hubstats:populate:setup_repo"].execute({repo: repo})
        end
      end
      puts "Finished with initial updating, grabbing extra info about pull requests"
      Rake::Task["hubstats:populate:update_pulls"].execute
    end

    desc "Pulls in all information for an indivdual repo"
    task :setup_repo, [:repo] => :environment do |t, args|
      repo = args[:repo]
      Hubstats::Repo.create_or_update(repo)
      Hubstats::GithubAPI.create_hook(repo)
      Rake::Task["hubstats:populate:users"].execute({repo: repo})
      Rake::Task["hubstats:populate:pulls"].execute({repo: repo})
      Rake::Task["hubstats:populate:comments"].execute({repo: repo})
      Rake::Task["hubstats:populate:labels"].execute({repo: repo})
    end 

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
      puts "Getting labels for " + repo.full_name
      Hubstats::GithubAPI.add_labels(repo)
    end

    desc "indivdually gets and updates pull requests"
    task :update_pulls => :environment do
      Hubstats::GithubAPI.update_pulls
    end

    desc "Updates labels for all repos"
    task :update_labels => :environment do
      Hubstats::Repo.all.each do |repo|
        Hubstats::GithubAPI.add_labels(repo)
      end
    end

    desc "Updates WebHooks for all repos"
    task :update_hooks, [:old_endpoint] => :environment do |t, args|
      Hubstats::Repo.all.each do |repo|
        Hubstats::GithubAPI.update_hook(repo, args[:old_endpoint])
      end
    end

    def repo_checker(args)
      raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args.nil?
      if args.is_a? String
        return Hubstats::Repo.where(full_name: args).first
      else 
        return args
      end
    end

  end
end
