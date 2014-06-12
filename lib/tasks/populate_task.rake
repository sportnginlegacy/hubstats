namespace :populate do

  desc "Pull members from Github saves in database"
  task :users, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. ['repos/sportngin/:repo']" if args.repo.nil? 
  
    contributors = Hubstats::GithubAPI.all(args.repo, 'contributors')

    contributors.each do |contributor|
      Hubstats::User.find_or_create_user(contributor)
    end
  end

  desc "Pull comments from Github saves in database"
  task :comments, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. [repos/sportngin/:repo]" if args.repo.nil?

    comments = Hubstats::GithubAPI.all(args.repo,'comments')

    comments.each do |comment|
      comm = Hubstats::Comment.find_or_create_comment(comment)
    end
  end

  desc "Pull pull requests from Github saves in database"
  task :pulls, [:repo] => :environment do |t, args|
    raise ArgumentError, "Must be called with repo argument. [repos/sportngin/:repo]" if args.repo.nil?

    pulls = Hubstats::GithubAPI.all(args.repo,"pulls")

    pulls.each do |pull|
      pr = Hubstats::PullRequest.find_or_create_pull(pull)
    end
  end

  desc "Pull repos from Github save to database"
  task :repos => :environment do
    client = Hubstats::GithubAPI.client
    if OCTOCONF.has_key?(:org_name)
      repos = client.organization_repositories(OCTOCONF[:org_name])
    else 
      repos = []
      OCTOCONF[:repo_list].each do |repo|
        repos << client.repository(repo)
      end
    end
    repos.each do |repo|
      re = Hubstats::Repo.find_or_create_repo(repo)
    end
  end


  # desc "Pull members,comments and pulls from Github save to database"
  # task :all => :environment do
  #   Rake::Task['app:populate:users'].invoke
  #   puts "Done populating users", "Populating comments, this may take a while..."
  #   Rake::Task['app:populate:comments'].invoke
  #   puts "Done populating comments", "Populating pull requests, this may take a while..."
  #   Rake::Task['app:populate:pulls'].invoke
  #   puts "Done populating pulls"
  # end

end