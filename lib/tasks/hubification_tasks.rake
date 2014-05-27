# desc "Explaining what the task does"
# task :hubification do
#   # Task goes here
# end

namespace :hubification do
  desc "Queries a list of users"
  task :signin => :environment do
    client = Octokit::Client.new(:login => 'elliothursh', :password => ENV['GITHUB_PASS'])

    user = client.user
    puts user.name
  end
end