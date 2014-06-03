module Hubification
  class GithubAPI

    def self.configure(options={})
      if access_token = ENV['GITHUB_API_TOKEN'] || options["access_token"]
        @client = Octokit::Client.new(access_token: access_token)
      elsif (ENV['CLIENT_ID'] || options["client_id"]) && (ENV['CLIENT_SECRET'] || options["client_secret"])
        @client = Octokit::Client.new(
          login: ENV['CLIENT_ID'] || options["client_id"], 
          password: ENV['CLIENT_SECRET'] || options["client_secret"]
        )
      else
        raise StandardError
      end
    rescue StandardError
      puts "Invalid GitHub credentials. See README for usage instructions."
      exit(1)
    end

    def self.client
      @client
    end

    def self.since(time, options = {})
      options.reverse_merge!(:state => 'closed', :sort => 'created', :direction => 'desc', :per_page => 30)
      again = true
      i = 0
      pulls = []

      while again do
        res = client.paginate('/repos/sportngin/ngin/pulls', :state => options[:state], :sort => options[:sort], :direction => options[:description], :page => (i += 1 ) )
        if res.length < options[:per_page]
          again = false
        end
        res.each do |pull|
          if pull.closed_at > time
            pulls << pull
          else
            again = false
            break
          end
        end
      end

      return pulls
    end

  end
end