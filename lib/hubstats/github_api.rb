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

    def self.pulls_since(repo_url, time, options={})
      options.reverse_merge!(:state => 'closed', :sort => 'created', :direction => 'desc', :per_page => 100)
      hub = client({:auto_paginate => true })
      hub.paginate(repo_url+'/pulls', :state => options[:state], :sort => options[:sort], :direction => options[:direction], :per_page => options[:per_page] ) do |data, last_response|
        while (last_response.rels[:next] && hub.rate_limit.remaining > 0)
          break if !last_response.data.detect{|v| v.closed_at.to_datetime > time.to_datetime}
          last_response = last_response.rels[:next].get
          data.concat(last_response.data) if last_response.data.is_a?(Array)
        end
        return data.reject!{|v| v.closed_at.to_datetime < time.to_datetime }
      end
    end

    def self.wait_limit(grab_size,rate_limit)
      if rate_limit.remaining < grab_size

        puts "Hit Github rate limit, waiting #{Time.at(rate_limit.resets_in).utc.strftime("%H:%M:%S")} to get more"
        sleep(rate_limit.resets_in)
      end
    end

    def self.inline(repo_name, kind, options={})
      path = ["repos",repo_name].join('/')
      octo = client({:auto_paginate => true })
      octo.paginate([path,kind].join('/'), options) do |data, last_response|
        while (last_response.rels[:next])
          last_response = last_response.rels[:next].get
          data.concat(last_response.data) if last_response.data.is_a?(Array)
          data.map{|v| route(v,kind,repo_name)}.clear
          wait_limit(1,octo.rate_limit)
        end
      end.map{|v| route(v,kind,repo_name)}.clear
    end

    def self.route(object, kind, repo_name = nil)
      if kind == "pulls/comments"
        repo = Hubstats::Repo.where(full_name: repo_name).first
        Hubstats::Comment.create_or_update(comment_setup(object,repo.id,"PullRequest"))
      elsif kind == "issues/comments"
        repo = Hubstats::Repo.where(full_name: repo_name).first
        Hubstats::Comment.create_or_update(comment_setup(object,repo.id,"Issue"))
      elsif kind == "comments"
        repo = Hubstats::Repo.where(full_name: repo_name).first
        Hubstats::Comment.create_or_update(comment_setup(object,repo.id,"Commit"))
      elsif kind == "pulls"
        Hubstats::PullRequest.create_or_update(pull_setup(object))
      end
    end
  end
end