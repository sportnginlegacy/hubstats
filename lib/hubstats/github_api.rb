module Hubstats
  class GithubAPI

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

    def self.all(repo_url,kind)
      client({:auto_paginate => true }).paginate([repo_url,kind].join('/'))
    end

    def self.wait_limit(grab_size,rate_limit)
      if rate_limit.remaining < grab_size
        puts "Hit Github rate limit, waiting to get more"
        sleep(rate_limit.resets_at)
      end
    end
  end
end