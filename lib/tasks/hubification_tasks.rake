require_relative "../hubification/github_api"

namespace :hubification do
  desc "Queries a list of users"
  task :signin => :environment do
    client = Hubification::GithubApi.client

    user = client.user
    puts user.name
  end

  desc "Outputs pull requests from ngin"
  task :pulls => :environment do
    time = "2014-04-26T19:01:12Z".to_datetime

    client = Hubification::GithubApi.client
    pulls = client.pull_requests('sportngin/ngin', :state => 'closed', :per_page => 100)
    pulls.each do |pull|
      puts pull.closed_at
    end
  end
end