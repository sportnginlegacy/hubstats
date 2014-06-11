namespace :populate do

  desc "Pull members from Github saves in database"
  task :users => :environment do
    contributors = Hubstats::GithubAPI.all('contributors')

    contributors.each do |contributor|
      Hubstats::User.find_or_create_user(contributor)
    end
  end

  desc "Pull comments from Github saves in database"
  task :comments => :environment do
    comments = Hubstats::GithubAPI.all('comments')

    comments.each do |comment|
      comm = Hubstats::Comment.find_or_create_comment(comment)
    end
  end

  desc "Pull pull requests from Github saves in database"
  task :pulls => :environment do
    pulls = Hubstats::GithubAPI.all("pulls")

    pulls.each do |pull|
      pr = Hubstats::PullRequest.find_or_create_pull(pull)
    end
  end

  desc "Pull members,comments and pulls from Github save to database"
  task :all => :environment do
    Rake::Task['app:populate:users'].invoke
    puts "Done populating users", "Populating comments, this may take a while..."
    Rake::Task['app:populate:comments'].invoke
    puts "Done populating comments", "Populating pull requests, this may take a while..."
    Rake::Task['app:populate:pulls'].invoke
    puts "Done populating pulls"
  end

end