# A variety of commands that can be used to populate the database information
namespace :hubstats do 
  namespace :populate do

    desc "Pull repos from Github saves in database"
    task :setup_repos => :environment do
      Hubstats::GithubAPI.get_repos.each do |repo|
        Rake::Task["hubstats:populate:setup_repo"].execute({repo: repo})
      end
      puts "Finished with initial population, grabbing extra info about pull requests"
      Rake::Task["hubstats:populate:update_pulls"].execute
      puts "Finished grabbing info about pull requests, populating teams"
      Rake::Task["hubstats:populate:teams"].execute
    end

    desc "Updates which repos hubstats tracks" 
    task :update_repos => :environment do
      Hubstats::GithubAPI.get_repos.each_with_index do |repo_chunk, index|
        unless Hubstats::Repo.where(full_name: repo.full_name).first
          Rake::Task["hubstats:populate:setup_repo"].execute({repo: repo})
        end

        if index % 10 == 0
          Hubstats::GithubAPI.wait_limit(true)
        end
      end

      puts "Finished with initial updating, grabbing extra info about pull requests"
      Rake::Task["hubstats:populate:update_pulls"].execute
      puts "Finished grabbing info about pull requests, populating teams"
      Rake::Task["hubstats:populate:teams"].execute
    end

    desc "Updates teams for past pull requests"
    task :update_teams_in_pulls => :environment do
      Rake::Task["hubstats:populate:update_teams_in_prs"].execute
    end

    desc "Updates the teams"
    task :update_teams => :environment do
      Rake::Task['hubstats:populate:teams'].execute
    end

    desc "Deprecates teams based on the octokit.yml file"
    task :deprecate_teams_from_file => :environment do
      Hubstats::GithubAPI.deprecate_teams_from_file
    end

    desc "Creates the webhook for the current org"
    task :setup_teams => :environment do
      Rake::Task['hubstats:populate:create_org_hook'].execute
    end

    task :create_org_hook => :environment do
      Hubstats::GithubAPI.create_org_hook(Hubstats.config.github_config["org_name"])
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

    desc "indivdually gets and updates all of the teams"
    task :teams => :environment do
      Hubstats::GithubAPI.update_teams
    end

    desc "updates the teams for all pull requests from past 365 days"
    task :update_teams_in_prs => :environment do
      Hubstats::PullRequest.update_teams_in_pulls(365)
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
