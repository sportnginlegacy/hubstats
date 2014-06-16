namespace :hubstats do

  desc "Create the database, load the schema, and pull data from Github (use hubstats:reset to also drop the db first)"
  task :setup => :environment do
    puts "Running rake db:create"
    Rake::Task['app:db:create'].invoke
    puts "Running rake db:migrate"
    Rake::Task['app:db:migrate'].invoke
    puts "Pulling data from Github. This may take a while..."
    Rake::Task['app:populate:all'].invoke
  end

  desc "Drops the database, then runs rake hubstats:setup"
  task :reset => :environment do
    puts "Droping Database"
    Rake::Task['app:db:drop'].invoke
    Rake::Task['app:hubstats:setup'].invoke
  end

end