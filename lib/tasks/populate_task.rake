namespace :populate do

  desc "Pull members from Github saves in database"
  task :users => :environment do
    contributors = Hubstats::GithubAPI.all('contributors')

    contributors.each do |contributor|
      find_or_create_user(contributor)
    end
  end

  desc "Pull comments from Github saves in database"
  task :comments => :environment do
    comments = Hubstats::GithubAPI.all('comments')

    comments.each do |comment|
      comm = find_or_create_comment(comment)
    end
  end

  desc "Pull pull requests from Github saves in database"
  task :pulls => :environment do
    pulls = Hubstats::GithubAPI.all("pulls")

    pulls.each do |pull|
      pr = find_or_create_pull(pull)
    end
  end
end

def find_or_create_user(github_user)
  github_user[:role] = github_user.delete :type  ##changing :type in to :role
  user_data = github_user.to_h.slice(*Hubstats::User.column_names.map(&:to_sym))
  user = Hubstats::User.where(:id => user_data[:id]).first_or_create(user_data)
  return user if user.save
  puts user.errors.inspect
end

def find_or_create_comment(github_comment)
  user = find_or_create_user(github_comment[:user])
  comment_data = github_comment.to_h.slice(*Hubstats::Comment.column_names.map(&:to_sym)).except(:user)
  comment = Hubstats::Comment.where(:id => comment_data[:id]).first_or_create(comment_data)
  return comment if comment.save
  puts comment.errors.inspect

end

def find_or_create_pull(github_pull)
  user = find_or_create_user(github_pull[:user])
  pull_data = github_pull.to_h.slice(*Hubstats::PullRequest.column_names.map(&:to_sym)).except(:user)
  pull = Hubstats::PullRequest.where(:id => pull_data[:id]).first_or_create(pull_data)
  return pull if pull.save
  puts pull.errors.inspect
end