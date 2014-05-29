module Hubification
  class GithubAPI
    
    def self.client
      @client ||= Octokit::Client.new(:login => ENV['GITHUB_USER'], :password => ENV['GITHUB_PASS'])
    end

    def self.since(time)
      again = true
      i = 0
      pulls = []

      while again do
        res = client.paginate('/repos/sportngin/ngin/pulls', :state => 'closed', :sort => 'updated', :direction => 'desc', :page => i += 1 )
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