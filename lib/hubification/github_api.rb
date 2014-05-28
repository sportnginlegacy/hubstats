module Hubification
  class GithubApi
    def self.client
      Octokit::Client.new(:login => ENV['GITHUB_USER'], :password => ENV['GITHUB_PASS'])
    end
  end
end