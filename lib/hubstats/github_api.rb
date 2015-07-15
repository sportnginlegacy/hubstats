module Hubstats
  class GithubAPI
    include HubHelper

    cattr_accessor :auth_info

    # Public - configures the information needed to receive webhooks from GitHub
    #
    # options - the options to be passed in or an empty hash
    #
    # Returns - the configured auth_info
    def self.configure(options = {})
      @@auth_info = {}
      if access_token = ENV['GITHUB_API_TOKEN'] || options["access_token"]
        @@auth_info[:access_token] = access_token
      else
        @@auth_info[:client_id] = ENV['CLIENT_ID'] || options["client_id"]
        @@auth_info[:client_secret] = ENV['CLIENT_SECRET'] || options["client_secret"]
      end
      @@auth_info
    end

    # Public - Checks that the options passed in are valid and configured correctly
    #
    # options - the options to be checked or an empty hash
    #
    # Returns - the new configured info
    def self.client(options = {})
      configure(Hubstats.config.github_auth) if @@auth_info.nil?
      ent = Octokit::Client.new(@@auth_info.merge(options))
      ent.user #making sure it was configured properly
      return ent
    end

    # Public - Gets all of a specific kind from a repo, and processes them.
    #
    # repo_name - the name of a repo
    # kind - a kind of object (pull,comment)
    # options - any possible option a particular kind of object
    #
    # Returns an array of that particular kind
    def self.inline(repo_name, kind, options = {})
      path = ["repos",repo_name,kind].join('/')
      octo = client({:auto_paginate => true})
      octo.paginate(path, options) do |data, last_response|
        last_response.data.each{|v| route(v,kind,repo_name)}.clear
        wait_limit(1,octo.rate_limit)
      end.each{|v| route(v,kind,repo_name)}.clear
    end

    # Public - Gets repos found in configuration file
    #
    # Returns - an array of github repo objects
    def self.get_repos
      if Hubstats.config.github_config.has_key?("org_name")
        repos = client.organization_repositories(Hubstats.config.github_config["org_name"])
      else
        repos = []
        Hubstats.config.github_config["repo_list"].each do |repo|
          repos << client.repository(repo)
        end
      end
      repos
    end

    # Public - Gets extra information on pull requests, e.g size, additions ...
    #
    # Returns - nothing
    def self.update_pulls
      grab_size = 250
      begin
        while Hubstats::PullRequest.where(deletions: nil).where(additions: nil).count > 0
          client = Hubstats::GithubAPI.client
          incomplete = Hubstats::PullRequest.where(deletions: nil).where(additions: nil).limit(grab_size)

          incomplete.each do |pull|
            repo = Hubstats::Repo.where(id: pull.repo_id).first
            pr = client.pull_request(repo.full_name, pull.number)
            Hubstats::PullRequest.create_or_update(HubHelper.pull_setup(pr))
          end
          wait_limit(grab_size,client.rate_limit)
        end
        puts "All Pull Requests are up to date"
      rescue Faraday::ConnectionFailed
        puts "Connection Timeout, restarting pull request updating"
        update_pulls
      end
    end

    # Public - Makes a new webhook from a repository
    #
    # repo - the repository that is attempting to have a hook made with
    #
    # Returns - the hook and a message (or just a message and no hook)
    def self.create_hook(repo)
      begin
        client.create_hook(
          repo.full_name,
          'web',
          {
            :url => Hubstats.config.webhook_endpoint,
            :content_type => 'json',
            :secret => Hubstats.config.webhook_secret
          },
          {
            :events => [
              'pull_request',
              'pull_request_review_comment',
              'commit_comment',
              'issues',
              'issue_comment',
              'member'
              ],
            :active => true
          }
        )
        puts "Hook on #{repo.full_name} successfully created"
      rescue Octokit::UnprocessableEntity
        puts "Hook on #{repo.full_name} already existed"
      rescue Octokit::NotFound
        puts "You don't have sufficient privileges to add an event hook to #{repo.full_name}"
      end
    end

    # Public - Delete webhook from github repository
    #
    # repo - a repo github object
    # old_endpoint - A string of the previous endpoint
    #
    # Return - nothing
    def self.delete_hook(repo, old_endpoint)
      begin
        client.hooks(repo.full_name).each do |hook|
          if hook[:config][:url] == old_endpoint
            Hubstats::GithubAPI.client.remove_hook(repo.full_name, hook[:id])
            puts "Successfully deleted hook with id #{hook[:id]} and url #{hook[:config][:url]} from #{repo.full_name}"
          end
        end
      rescue Octokit::NotFound
        puts "You don't have sufficient privileges to remove an event hook to #{repo.full_name}"
      end
    end

    # Public - updates a hook if it exists, otherwise creates one
    #
    # repo - a repo github object
    # old_endpoint - A string of the previous endpoint
    #
    # Returns - the new hook
    def self.update_hook(repo, old_endpoint = nil)
      delete_hook(repo, old_endpoint) unless old_endpoint == nil
      create_hook(repo)
    end

    # Public - gets labels for a particular label
    #
    # repo - a repo github object
    #
    # Returns - all the labels for a given repo
    def self.get_labels(repo)
      labels = []
      octo = Hubstats::GithubAPI.client({:auto_paginate => true})
      github_labels = octo.labels(repo.full_name)
      github_labels.each do |label|
        label_hash = label.to_h if label.respond_to? :to_h
        label_data = label_hash.slice(*Hubstats::Label.column_names.map(&:to_sym))
        labels << Hubstats::Label.where(:name => label_data[:name]).first_or_create(label_data)
      end
      labels
    end

    # Public - gets the label for a given pull request
    #
    # repo_name - a the repo_name
    # pull_request_number - the number of the pull_request you want labels of
    #
    # Returns - the issue
    def self.get_labels_for_pull(repo_name, pull_request_number)
      issue = client.issue(repo_name, pull_request_number)
      issue[:labels]
    end

    # Public - Gets all the labels for a repo, adds all labels to a pull
    #
    # repo - the particular repository, you want to add labels to
    def self.add_labels(repo)
      get_labels(repo).each do |label|
        inline(repo.full_name,'issues', labels: label.name, state: 'all')
      end
    end

    # Public - Puts the process to sleep if there is a "timeout" before continuing
    #
    # grab_size - the amount of data that is being attempted to grab
    # rate_limit - the amount of time to wait to grab data
    #
    # Returns - nothing
    def self.wait_limit(grab_size, rate_limit)
      if rate_limit.remaining < grab_size
        puts "Hit Github rate limit, waiting #{Time.at(rate_limit.resets_in).utc.strftime("%H:%M:%S")} to get more"
        sleep(rate_limit.resets_in)
      end
    end

    # Public - Routes to the correst setup methods to be used to update or create comments or PRs
    #
    # object - the new thing to be updated or created
    # kind - the type of thing (pull comment, issue comment, normal comment, pull, or issue)
    # repo_name - the name of the repository to which object belongs (optional)
    #
    # Returns - nothing, but does update the object
    def self.route(object, kind, repo_name = nil)
      if kind == "pulls/comments"
        repo = Hubstats::Repo.where(full_name: repo_name).first
        Hubstats::Comment.create_or_update(HubHelper.comment_setup(object,repo.id,"PullRequest"))
      elsif kind == "issues/comments"
        repo = Hubstats::Repo.where(full_name: repo_name).first
        Hubstats::Comment.create_or_update(HubHelper.comment_setup(object,repo.id,"Issue"))
      elsif kind == "comments"
        repo = Hubstats::Repo.where(full_name: repo_name).first
        Hubstats::Comment.create_or_update(HubHelper.comment_setup(object,repo.id,"Commit"))
      elsif kind == "pulls"
        Hubstats::PullRequest.create_or_update(HubHelper.pull_setup(object))
      elsif kind == "issues"
        if object[:pull_request]
          repo = Hubstats::Repo.where(full_name: repo_name).first
          pull_request = Hubstats::PullRequest.where(repo_id: repo.id).where(number: object[:number]).first
          pull_request.add_labels(object[:labels])
        end
      end
    end
  end
end
