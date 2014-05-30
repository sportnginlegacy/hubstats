namespace :hubification do
  desc "Queries a list of users"
  task :signin => :environment do
    client = Hubification::GithubAPI.client

    user = client.user
    puts user.login
  end

  desc "Queries a list of users"
  task :members  => :environment do
    client = Hubification::GithubAPI.client

    org = client.org('Sportngin')
    puts org.name
  end

  desc "Outputs pull requests from ngin"
  task :pulls => :environment do
    time = "2014-04-26T19:01:12Z".to_datetime

    client = Hubification::GithubAPI.client
    pulls = client.pull_requests('sportngin/ngin', :state => 'closed', :per_page => 100)
    pulls.each do |pull|
      puts pull.closed_at
    end
  end

  desc "Outputs pull requests from ngin until time"
  task :since => :environment do
    pulls = Hubification::GithubAPI.since("2014-05-20T19:01:12Z".to_datetime, :state => "closed")

    pulls.each do |pull|
      puts pull.title.to_s + ": " + pull.closed_at.to_s
    end
  end

  desc "Outputs pull requests from ngin until time"
  task :events => :environment do
    Hubification::GithubAPI.client
    
  end

end