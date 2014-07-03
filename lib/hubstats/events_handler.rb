module Hubstats
  class EventsHandler

    def route(payload, type) 
      puts type
      case type
      when "issue_comment", "IssueCommentEvent"
        comment_processor(payload,"Issue")
      when "commit_comment", "CommitCommentEvent"
        comment_processor(payload,"Commit")
      when "pull_request", "PullRequestEvent"
        pull_processor(payload)
      when "pull_request_review_comment", "PullRequestReviewCommentEvent"
        comment_processor(payload,"PullRequest")
      end
    end

    def pull_processor(payload)
      pull_request = payload[:pull_request]
      pull_request[:repository] = payload[:repository]
      
      Hubstats::PullRequest.create_or_update(pull_request)
    end

    def comment_processor(payload,kind)
      comment = payload[:comment]
      comment[:kind] = kind
      comment[:repo_id] = payload[:repository][:id]
      comment[:pull_number] = get_pull_number(payload)

      Hubstats::Comment.create_or_update(comment)
    end

    #grabs the number off of anyone of the various places it can be
    def get_pull_number(payload)
      if payload[:pull_request]
        return payload[:pull_request][:number]
      elsif payload[:issue]
        return payload[:issue][:number]
      elsif payload[:comment][:pull_request_url]
        return payload[:comment][:pull_request_url].split('/')[-1]
      else
        return nil
      end
    end

  end
end
