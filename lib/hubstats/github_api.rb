module Hubstats
  class GithubAPI
    include HubHelper

    cattr_accessor :auth_info
    
    def self.configure(options={})
      @@auth_info = {}
      if access_token = ENV['GITHUB_API_TOKEN'] || options["access_token"]
        @@auth_info[:access_token] = access_token
      else
        @@auth_info[:client_id] = ENV['CLIENT_ID'] || options["client_id"]
        @@auth_info[:client_secret] = ENV['CLIENT_SECRET'] || options["client_secret"]
      end
      @@auth_info
    end

    def self.client(options={})
      configure(Hubstats.config.github_auth) if @@auth_info.nil?
      ent = Octokit::Client.new(@@auth_info.merge(options))
      ent.user #making sure it was configured properly
      return ent
    end

    def self.inline(repo_name, kind, options={})
      path = ["repos",repo_name,kind].join('/')
      octo = client({:auto_paginate => true })
      octo.paginate(path, options) do |data, last_response|
        last_response.data.each{|v| route(v,kind,repo_name)}.clear
        wait_limit(1,octo.rate_limit)
      end.each{|v| route(v,kind,repo_name)}.clear
    end

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
        puts "You don't have sufficient privledges to add an event hook to #{repo.full_name}"
      end
    end

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

          Hubstats::GithubAPI.wait_limit(grab_size,client.rate_limit)
        end
        puts "All Pull Requests are up to date"
      rescue Faraday::ConnectionFailed
        puts "Connection Timeout, restarting pull request updating"
        update_pulls
      end
    end

    def self.update_labels
      puts "Adding labels to pull requests"
      Hubstats::Repo.all.each do |repo|
        Hubstats::GithubAPI.client({:auto_paginate => true}).labels(repo.full_name).each do |label|
          label_hash = label.to_h if label.respond_to? :to_h
          label_data = label_hash.slice(*Hubstats::Label.column_names.map(&:to_sym))
          label = Hubstats::Label.where(:name => label_data[:name]).first_or_create(label_data)
        end

        Hubstats::Label.all.each do |label|
          inline(repo.full_name,'issues', labels: label.name, state: 'closed')
          inline(repo.full_name,'issues', labels: label.name, state: 'open')
        end
      end
    end

    def self.wait_limit(grab_size,rate_limit)
      if rate_limit.remaining < grab_size
        puts "Hit Github rate limit, waiting #{Time.at(rate_limit.resets_in).utc.strftime("%H:%M:%S")} to get more"
        sleep(rate_limit.resets_in)
      end
    end

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
    