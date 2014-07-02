module HubHelper
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

  def self.comment_setup(comment, repo_id, kind)
    comment[:repo_id] = repo_id
    comment[:pull_number] = get_pull_number(comment)
    comment[:kind] = kind
    return comment
  end

  def self.pull_setup(pull_request)
    pull_request[:repository] = pull_request[:base][:repo]
    return pull_request
  end
end
