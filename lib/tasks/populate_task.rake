namespace :populate do

  desc "Pull members from Github saves in database"
  task :users => :environment do
    client = Hubification::GithubAPI.client
    contributors = Hubification::GithubAPI.all('contributors')

    contributors.each do |contributor|
      find_or_create_user(contributor)
    end
  end

  desc "Pull comments from Github saves in database"
  task :comments => :environment do
    client = Hubification::GithubAPI.client
    comments = Hubification::GithubAPI.all('comments')

    comments.each do |comment|
      comm = find_or_create_comment(comment)
    end
  end

  desc "Pull pullrequests from Github saves in database"
  task :pulls => :environment do
    client = Hubification::GithubAPI.client
    pulls = Hubification::GithubAPI.all("pulls")

    pulls.each do |pull|
      pr = find_or_create_pull(pull)
    end
  end
end

def find_or_create_user(user)
  if (oldUser = Hubification::User.where(:id => user[:id]).first).nil?
    member = (user.to_h).except(:contributions)
    member[:role] = member.delete :type  ##changing :type in to :role
    return newUser = Hubification::User.create(member)
  else
    return oldUser
  end
end

def find_or_create_comment(comment)
  user = find_or_create_user(comment[:user])
  if (Hubification::Comment.where(:id => comment[:id]).first).nil?
    comm = (comment.to_h).except(:user)
    newComment = Hubification::Comment.new(comm)
    newComment[:user_id] = user[:id]
    newComment.save()
    puts newComment.errors.inspect
  end
end

def find_or_create_pull(pull)
  user = find_or_create_user(pull[:user])
  if (Hubification::PullRequest.where(:id => pull[:id]).first).nil?
    pr = (pull.to_h).except(:head).except(:base).except(:milestone).except(:assignee).except(:_links).except(:user)
    pull_request = Hubification::PullRequest.new(pr)
    pull_request[:user_id] = user[:id]
    pull_request.save()
    puts pull_request.errors.inspect
  end
end