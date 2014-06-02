module Hubification
  class GithubAPI

    def self.configure(options={})
      if options
        if options.has_key?('access_token')
          @client ||= Octokit::Client.new(:access_token => options["access_token"])
        elsif option.has_key?('login') && option.has_key?('password')
          @client ||= Octokit::Client.new(:login => option['login'], :password => option['password'])
        else
          puts "options must include either access_token or login and password"
          exit
        end
      elsif !ENV['GITHUB_API_TOKEN'].nil? || !(ENV['GITHUB_LOGIN'].nil? && ENV['GITHUB_PASSWORD'].nil?)
        if !ENV['GITHUB_API_TOKEN'].nil?
          @client ||= Octokit::Client.new(:access_token => ENV['GITHUB_API_TOKEN'])
        elsif !(ENV['GITHUB_LOGIN'].nil? && ENV['GITHUB_PASSWORD'].nil?)
           @client ||= Octokit::Client.new(:login => ENV['GITHUB_LOGIN'], :password => ENV['GITHUB_PASSWORD'])
        else 
          puts "Environment variables must include either GITHUB_API_TOKEN or LOGIN and PASSWORD"
          exit
        end
      else
        puts "You must include either a ocktokit.yml file or appropriate environmen variables"
        exit
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