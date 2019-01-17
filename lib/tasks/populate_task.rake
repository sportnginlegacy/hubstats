# A variety of commands that can be used to populate the database information
namespace :hubstats do
  namespace :populate do

    desc "Pull repos from Github saves in database"
    task :setup => :environment do
      Hubstats::GithubAPI.get_repos.each do |repo|
        setup_repo(repo)
      end
      puts "Finished with initial population, grabbing extra info about pull requests"
      update_pulls
      puts "Finished grabbing info about pull requests, populating teams"
      update_teams
    end

    desc "Updates which repos hubstats tracks"
    task :update => :environment do
      Hubstats::GithubAPI.get_repos.each_with_index do |repo, index|
        unless Hubstats::Repo.where(full_name: repo.full_name).first
          setup_repo(repo)
        end

        if index % 10 == 0
          Hubstats::GithubAPI.wait_limit(true)
        end
      end

      puts "Finished with initial updating, grabbing extra info about pull requests"
      update_pulls
      puts "Finished grabbing info about pull requests, populating teams"
      update_teams
    end

    desc "Updates teams for past pull requests"
    task :update_teams_in_pulls => :environment do
      update_teams_in_prs
    end

    desc "Updates the teams"
    task :update_teams => :environment do
      update_teams
    end

    desc "Deprecates teams based on the octokit.yml file"
    task :deprecate_teams_from_file => :environment do
      Hubstats::GithubAPI.deprecate_teams_from_file
    end

    desc "Creates the webhook for the current org"
    task :create_organization_hook => :environment do
      create_org_hook
    end

    task :create_org_hook => :environment do
      create_org_hook
    end

    private def create_org_hook
      Hubstats::GithubAPI.create_org_hook(Hubstats.config.github_config["org_name"])
    end

    private def setup_repo(repo)
      Hubstats::Repo.create_or_update(repo)
      Hubstats::GithubAPI.create_hook(repo)
      # These are the pieces that take forever when we run the command. Let's not do this, and just make
      # hubstats accurate from this time on out.
      # populate_users(repo)
      # populate_pulls(repo)
      # populate_comments(repo)
      # populate_labels(repo)
    end

    private def populate_users(repo)
      repo = repo_checker(repo)
      puts "Adding contributors to " + repo.full_name

      users = Hubstats::GithubAPI.client({:auto_paginate => true}).contribs(repo.full_name)
      users.each do |contributor|
        cont = Hubstats::User.create_or_update(contributor)
      end unless users == "" # there are no contributors because there are no commits yet
    end

    private def populate_comments(repo)
      repo = repo_checker(repo)
      puts "Adding comments to " + repo.full_name

      pull_comments = Hubstats::GithubAPI.inline(repo.full_name,'pulls/comments')
      issue_comments = Hubstats::GithubAPI.inline(repo.full_name,'issues/comments')
      commit_comments = Hubstats::GithubAPI.inline(repo.full_name,'comments')
    end

    private def populate_pulls(repo)
      repo = repo_checker(repo)
      puts "Adding pulls to " + repo.full_name

      pull_requests = Hubstats::GithubAPI.inline(repo.full_name,'pulls', :state => "all")
    end

    private def populate_labels(repo)
      repo = repo_checker(repo)
      puts "Getting labels for " + repo.full_name
      Hubstats::GithubAPI.add_labels(repo)
    end

    private def update_pulls
      Hubstats::GithubAPI.update_pulls
    end

    private def update_teams
      Hubstats::GithubAPI.update_teams
    end

    private def update_teams_in_prs
      Hubstats::PullRequest.update_teams_in_pulls(365)
    end

    private def repo_checker(args)
      raise ArgumentError, "Must be called with repo argument. [:org/:repo]" if args.nil?
      if args.is_a? String
        return Hubstats::Repo.where(full_name: args).first
      else
        return args
      end
    end
  end
end
