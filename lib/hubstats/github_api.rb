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
      configure() if @@auth_info.nil?
      ent = Octokit::Client.new(@@auth_info.merge(options))
      ent.user #making sure it was configured properly
      return ent
    end

    # def self.pulls_since(repo_name, time, options={})
    #   options.reverse_merge!(:state => 'all', :sort => 'created', :direction => 'desc', :per_page => 100)
    #   path = ["repos",repo_name,'pulls'].join('/')
    #   hub = client({:auto_paginate => true })
    #   hub.paginate(path, :state => options[:state], :sort => options[:sort], :direction => options[:direction], :per_page => options[:per_page] ) do |data, last_response|
    #     last_response.data.reject!{|v| v.closed_at.to_datetime < time.to_datetime }.each{|v| route(v,'pulls',repo_name)}.clear
    #     break if !last_response.data.detect{|v| v.closed_at.to_datetime > time.to_datetime}
    #   end.reject!{|v| v.closed_at.to_datetime < time.to_datetime }.each{|v| route(v,'pulls',repo_name)}.clear
    # end

    def self.inline(repo_name, kind, options={})
      path = ["repos",repo_name,kind].join('/')
      octo = client({:auto_paginate => true })
      octo.paginate(path, options) do |data, last_response|
        data.each{|v| route(v,kind,repo_name)}
        data = last_response.data
        wait_limit(1,octo.rate_limit)
      end
    end

    def self.create_hook(repo)
      begin
        client.create_hook(
          repo.full_name,
          'web',
          {
            :url => 'https://commissioner.sportngin.com/hubstats/handler',
            :content_type => 'json'
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
      end
    end
  end
end
    