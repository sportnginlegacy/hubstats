module Hubification
  class GithubAPI

    def self.configure(options={})
      begin
        if options["access_token"]
          @client ||= Octokit::Client.new(:access_token => options["access_token"])
        elsif options["login"] && options["password"]
          @client ||= Octokit::Client.new(:login => options["login"], :password => options["password"])
        end
      rescue
        raise "You must have a .octokit.yml file in your app's config folder"
      end
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