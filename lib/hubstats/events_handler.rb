module Hubstats
  class EventsHandler
    # Public - Processes comments and PRs
    #
    # payload - the data that we will be processing
    # type - the type of data that payload is
    #
    # Returns - nothing
    def route(payload, type)
      case type
      when "issue_comment", "IssueCommentEvent"
        comment_processor(payload, "Issue") # comment on a pull request
      when "commit_comment", "CommitCommentEvent"
        comment_processor(payload, "Commit") # comment on a pull request commit
      when "pull_request_review_comment", "PullRequestReviewCommentEvent"
        comment_processor(payload, "PullRequest") # comment on a pull request review
      when "pull_request", "PullRequestEvent"
        pull_processor(payload) # new pull request
      when "membership", "MembershipEvent", "team", "TeamEvent"
        team_processor(payload) # adding/editing/deleting/modifying teams
      when "repository", "RepositoryEvent"
        repository_processor(payload) # adding repositories
      end
    end

    # Private - Gets the information for the PR, creates/updates the new PR, grabs the labels, and makes new labels;
    #  if the label qa-approved is added or removed, a new QA Signoff record will be made
    #
    # payload - the information that we will use to get data off of
    #
    # Returns - nothing, but creates/updates the PR and adds appropriate labels
    private def pull_processor(payload)
      pull_request = payload[:pull_request]
      pull_request[:repository] = payload[:repository]
      new_pull = Hubstats::PullRequest.create_or_update(pull_request.with_indifferent_access)

      if payload[:github_action].include?('labeled')
        organize_qa_signoffs(payload, new_pull)
      else
        add_labels_to_pull(new_pull)
      end

      new_pull.save!
    end

    # Private - Gets the information for the new comment and updates it
    #
    # payload - the information that we will use to get data off of
    #
    # Returns - nothing, but updates the comment
    private def comment_processor(payload, kind)
      comment = payload[:comment]
      comment[:kind] = kind
      comment[:repo_id] = payload[:repository][:id]
      comment[:pull_number] = get_pull_number(payload)
      Hubstats::Comment.create_or_update(comment.with_indifferent_access)
    end

    # Private - Gets the information for the team in the payload and updates it appropriately
    #
    # payload - the information that we will use to get the data off of
    #
    # Returns - nothing, but updates or makes the team
    private def team_processor(payload)
      # Adding a new hubstats team or adding/removing a person to/from a team
      if (payload[:scope] == "team" || payload[:github_action] == "edited") &&
          Hubstats::Team.designed_for_hubstats?(payload[:team][:description])
        Hubstats::Team.create_or_update(payload[:team].with_indifferent_access)
        hubstats_team = Hubstats::Team.where(name: payload[:team][:name]).first
        hubstats_user = payload[:member] ? Hubstats::User.create_or_update(payload[:member]) : Hubstats::User.create_or_update(payload[:sender])
        Hubstats::Team.update_users_in_team(hubstats_team, hubstats_user, payload[:github_action])
      end

      # Deleting a hubstats team
      if payload[:scope] == "organization" && payload[:github_action] == "removed"
        deprecate_team(payload)
      end
    end

    # Private - Gets the information for the repository in the payload and creates/updates it
    #
    # payload - the information that we will use to get the data off of
    #
    # Returns - nothing, but updates or makes the repository
    private def repository_processor(payload)
      if payload[:github_action] == "created" # it's a new repository
        Hubstats::Repo.create_or_update(payload[:repository].with_indifferent_access)
        Hubstats::GithubAPI.create_repo_hook(payload[:repository].with_indifferent_access)
      end
    end

    # Private - Grabs the PR number off of any of the various places it can be
    #
    # payload - the thing that we will use to try to attain the PR number
    #
    # Returns - the PR number
    private def get_pull_number(payload)
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

    # Private - Will add QA signoffs to a pull request if they're present
    #
    # payload - data that we can add signoffs to
    # new_pull - the pull request we just made or updated
    #
    # Returns - nothing
    private def organize_qa_signoffs(payload, new_pull)
      if payload[:github_action].include?('unlabeled') && payload[:label][:name].include?('qa-approved')
        Hubstats::QaSignoff.remove_signoff(payload[:repository][:id], payload[:pull_request][:id])
      elsif payload[:label][:name].include?('qa-approved')
        Hubstats::QaSignoff.first_or_create(payload[:repository][:id], payload[:pull_request][:id], payload[:sender][:id])
      end
      new_pull.update_label(payload)
    end

    # Private - Will add labels to pull requests
    #
    # new_pull - the pull request we just made or updated
    #
    # Returns - nothing
    private def add_labels_to_pull(new_pull)
      repo_name = Hubstats::Repo.where(id: new_pull.repo_id).first.full_name
      labels = Hubstats::GithubAPI.get_labels_for_pull(repo_name, new_pull.number)
      new_pull.add_labels(labels)
    end

    # Private - Will deprecate the team if it is in the DB and needs to be deprecated
    #
    # payload - data that we can add signoffs to
    #
    # Returns - nothing
    private def deprecate_team(payload)
      hubstats_team = Hubstats::Team.where(name: payload[:team][:name]).first
      hubstats_team.deprecate_team if (hubstats_team && hubstats_team[:hubstats])
    end
  end
end
