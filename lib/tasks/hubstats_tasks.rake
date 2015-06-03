namespace :hubstats do

  desc "Create the database, load the schema, and pull data from Github (use hubstats:reset to also drop the db first)"
  task :setup => :environment do
    puts "Running rake db:create"
    Rake::Task["db:create"].invoke
    puts "Running rake db:migrate"
    Rake::Task["db:migrate"].invoke
    puts "Pulling data from Github. This may take a while..."
    Rake::Task["hubstats:populate:setup_repos"].invoke
  end

  desc "Drops the database, then runs rake hubstats:setup"
  task :reset => :environment do
    puts "Droping Database"
    Rake::Task["db:drop"].invoke
    Rake::Task["hubstats:setup"].invoke
  end

  desc "Updates changes to the config file"
  task :update => :environment do
    puts "Updating repos"
    Rake::Task["hubstats:populate:update_repos"].invoke
  end

  desc "Updates the seed"
  task :seed => :environment do
    puts "Updating seed"
    Rake::Task["db:seed"].invoke
  end

end
