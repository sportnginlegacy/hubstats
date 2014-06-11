namespace :hubstats do

  desc "Queries the list of contributors to the repo"
  task :members => :environment do
    contributors = Hubstats::GithubAPI.all('contributors')

    contributors.each do |contributor|
      puts contributor.login
    end

  end

  desc "Outputs pull requests from ngin"
  task :pulls => :environment do
    time = "2014-04-26T19:01:12Z".to_datetime

    client = Hubstats::GithubAPI.client
    pulls = client.pull_requests('sportngin/ngin', :state => 'closed', :per_page => 100)
    pulls.each do |pull|
      puts pull.closed_at
    end
  end

  desc "Outputs pull requests from ngin until time"
  task :since, [:time] => :environment do |t, args|
    begin
      time = Time.parse(args.time).to_datetime
    rescue
      raise ArgumentError, "Must be called with time argument, e.g. since[:time] where :time = 'YYYY-MM-DD' "
    end
    pulls = Hubstats::GithubAPI.pulls_since(time, :state => "closed")

    pulls.each do |pull|
      puts pull.closed_at.to_s
    end
  end

  desc "Outputs all pull requests from until"
  task :all => :environment do
    pulls = Hubstats::GithubAPI.all('issues')

    pulls.each do |pull|
      puts pull.number
    end
  end

end