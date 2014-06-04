module Hubification
  class GithubAPI


    def self.configure(options={})
      if access_token = ENV['GITHUB_API_TOKEN'] || options["access_token"]
        @client = Octokit::Client.new(access_token: access_token)
      else
        @client = Octokit::Client.new(
          client_id: ENV['CLIENT_ID'] || options["client_id"], 
          client_secret: ENV['CLIENT_SECRET'] || options["client_secret"]
        )
      end

      # Calling API to make sure it configured properly
      @client.user

      @client
    end

    def self.client
      @client ||= self.configure()
    end

    def self.since(time, options={})
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

    def self.all(kind, options={})
      options.reverse_merge!(:per_page => 30)
      again = true
      i = 0
      info = []
      while again do 
        res = client.paginate('/repos/sportngin/ngin/'+kind, :per_page => 30, :page => (i += 1 ) )

        if res.length < options[:per_page]
          again = false
        end
        info << res

      end

      return info.flatten
    end


  end
end