namespace :populate do

  desc "Pull members from Github saves in database"
  task :members => :environment do
    client = Hubification::GithubAPI.client
    contributors = Hubification::GithubAPI.all('contributors')

    contributors.each do |contributor|
      member = (contributor.to_h).except(:contributions)
      member[:role] = member.delete :type

      user = Hubification::User.create(member)
    end
  end

  desc "Pull comments from Github saves in database"
  task :comments => :environment do
    client = Hubification::GithubAPI.client
    comments = Hubification::GithubAPI.all('comments')
    puts comments.length
    comments.each do |comment|
      puts comment.inspect
      comm = Hubification::User.create(comment)
    end
    # contributors.each do |contributor|
    #   member = (contributor.to_h).except(:contributions)
    #   member[:role] = member.delete :type

    #   user = Hubification::User.create(member)
    # end
  end  

end