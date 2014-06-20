module Hubstats
  class EventsHandler
    attr_accessor :pulls,:other

    def initialize()
      @pulls = 0
      @other = 0
    end

    def route(event) 
      case event[:type]
      when "IssueCommentEvent"
        comment_processor(event,"Issue")
      when "CommitCommentEvent"
        comment_processor(event,"Commit")
      when "PullRequestEvent"
        pull_processor(event)
      when "PullRequestReviewCommentEvent"
        comment_processor(event,"PullRequest")
      end
    end

    def pull_processor(event)
      pull_request = event[:payload][:pull_request]
      if event[:payload][:action] == 'closed'
        pull = Hubstats::PullRequest.find_or_create_pull(pull_request)
      end
    end

    def comment_processor(event,type)
      comment = event[:payload][:comment]
      comment[:kind] = type
      comment[:repo_id] = event[:repo][:id]
      comment[:pull_number] = get_pull_number(event)

      Hubstats::Comment.find_or_create_comment(comment)
    end


    #grabs the number off of anyone of the various places it can be
    def get_pull_number(event)
      if event[:payload][:pull_request]
        return event[:payload][:pull_request][:number]
      elsif event[:payload][:issue]
        return event[:payload][:issue][:number]
      elsif event[:payload][:comment][:pull_request_url]
        return event[:payload][:comment][:pull_request_url].split('/')[-1]
      else
        return nil
      end
    end

  end
end
