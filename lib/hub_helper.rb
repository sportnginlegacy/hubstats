module HubHelper

  # Public - Gets the PR number from the comment
  #
  # comment - the comment that we will get the PR number from
  #
  # Returns - either the PR number or nil
  def self.get_pull_number(comment)
    if comment[:pull_request]
      return comment[:pull_request][:number]
    elsif comment[:issue_url]
      return comment[:issue_url].split('/')[-1]
    elsif comment[:pull_request_url]
      return comment[:pull_request_url].split('/')[-1]
    else
      return nil
    end
  end

  # Public - Sets the comment's repo_id, pull_number, and type.
  #
  # comment - the comment that will be updated
  # repo_id - the id of the repo that the comment belongs to
  # kind - the type of comment (pull request, issue, or commit)
  #
  # Returns - the PR with the new repository
  def self.comment_setup(comment, repo_id, kind)
    comment[:repo_id] = repo_id
    comment[:pull_number] = get_pull_number(comment)
    comment[:kind] = kind
    return comment
  end

  # Public - Sets the PR's repository.
  #
  # pull_request - the PR that is passed in
  #
  # Returns - the PR with the new repository
  def self.pull_setup(pull_request)
    pull_request[:repository] = pull_request[:base][:repo]
    return pull_request
  end
end
