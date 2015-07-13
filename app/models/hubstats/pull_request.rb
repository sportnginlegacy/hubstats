module Hubstats
  class PullRequest < ActiveRecord::Base
    
    # Various checks that can be used to filter, sort, and find info about pull requests.
    scope :closed_in_date_range, lambda {|start_date, end_date| where("hubstats_pull_requests.closed_at BETWEEN ? AND ?", start_date, end_date)}
    scope :updated_in_date_range, lambda {|start_date, end_date| where("hubstats_pull_requests.updated_at BETWEEN ? AND ?", start_date, end_date)}
    scope :created_in_date_range, lambda {|start_date, end_date| where("hubstats_pull_requests.created_at BETWEEN ? AND ?", start_date, end_date)}
    scope :merged_in_date_range, lambda {|start_date, end_date| where("hubstats_pull_requests.merged").where("hubstats_pull_requests.merged_at BETWEEN ? AND ?", start_date, end_date)}
    scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}
    scope :belonging_to_team, lambda {|team_id| where(team_id: team_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}
    scope :belonging_to_deploy, lambda {|deploy_id| where(deploy_id: deploy_id)}
    scope :belonging_to_repos, lambda {|repo_id| where(repo_id: repo_id.split(',')) if repo_id}
    scope :belonging_to_users, lambda {|user_id| where(user_id: user_id.split(',')) if user_id}
    scope :group, lambda {|group| group_by(:repo_id) if group }
    scope :with_state, lambda {|state| (where(state: state) unless state == 'all') if state}
    scope :with_label, lambda {|label_name| joins(:labels).where(hubstats_labels: {name: label_name.split(',')}) if label_name}
    scope :distinct, select("DISTINCT hubstats_pull_requests.*")
    scope :with_repo_name, select('DISTINCT hubstats_repos.name as repo_name, hubstats_pull_requests.*').joins("LEFT JOIN hubstats_repos ON hubstats_repos.id = hubstats_pull_requests.repo_id")
    scope :with_user_name, select('DISTINCT hubstats_users.login as user_name, hubstats_pull_requests.*').joins("LEFT JOIN hubstats_users ON hubstats_users.id = hubstats_pull_requests.user_id")

    attr_accessible :id, :url, :html_url, :diff_url, :patch_url, :issue_url, :commits_url,
      :review_comments_url, :review_comment_url, :comments_url, :statuses_url, :number,
      :state, :title, :body, :created_at, :updated_at, :closed_at, :merged_at, 
      :merge_commit_sha, :merged, :mergeable, :comments, :commits, :additions,
      :deletions, :changed_files, :user_id, :repo_id, :merged_by, :team_id

    belongs_to :user
    belongs_to :repo
    belongs_to :deploy
    belongs_to :team
    has_and_belongs_to_many :labels, :join_table => "hubstats_labels_pull_requests"

    # Public - Makes a new pull request from a GitHub webhook. Finds user_id and repo_id based on users and repos 
    # that are already in the Hubstats database. Updates the user_id of a deploy if the pull request has been merged in a deploy.
    # If the user who makes the PR has a team, then it will update the team_id of the PR to match the team the user
    # belongs to.
    #
    # github_pull - the info that is from Github about the new or updated pull request
    #
    # Returns - the pull request 
    def self.create_or_update(github_pull)
      github_pull = github_pull.to_h.with_indifferent_access if github_pull.respond_to? :to_h

      user = Hubstats::User.create_or_update(github_pull[:user])
      github_pull[:user_id] = user.id

      github_pull[:repository][:updated_at] = github_pull[:updated_at]
      repo = Hubstats::Repo.create_or_update(github_pull[:repository])
      github_pull[:repo_id] = repo.id

      pull_data = github_pull.slice(*column_names.map(&:to_sym))

      pull = where(:id => pull_data[:id]).first_or_create(pull_data)

      if github_pull[:merged_by] && github_pull[:merged_by][:id]
        pull_data[:merged_by] = github_pull[:merged_by][:id]
        deploy = Hubstats::Deploy.where(id: pull.deploy_id, user_id: nil).first
          if deploy
            deploy.user_id = pull_data[:merged_by]
            deploy.save!
          end
      end

      if user.team && user.team.id
        pull_data[:team_id] = user.team.id
      end

      return pull if pull.update_attributes(pull_data)
      Rails.logger.warn pull.errors.inspect
    end

    # Public - Adds any labels to the labels database if the labels passed in aren't already there.
    #
    # labels - the labels to be added to the db
    #
    # Returns - the new labels
    def add_labels(labels)
      labels.map!{|label| Hubstats::Label.first_or_create(label) }
      self.labels = labels
    end

    # Public - Filters all of the pull requests between start_date and end_date that are the given state
    # (passed as part of params) that belong to the params' users and repos.
    #
    # params - the params that are passed in (likely from the URL)
    # start_date - the start of the date range
    # end_date - the end of the data range
    #
    # Returns - the PRs that fit all of the below sql queries
    def self.all_filtered(params, start_date, end_date)
      filter_based_on_date_range(start_date, end_date, params[:state])
       .belonging_to_users(params[:users])
       .belonging_to_repos(params[:repos])
    end

    # Public - Finds all of the PRs with the current state, and then filters to ones that have been updated in
    # between the start_date and end_date.
    #
    # start_date - the start of the date range
    # end_date - the end of the data range
    # state - the current state (open, closed, or all) of the PRs
    #
    # Returns - the PRs that are within the date range and that are the state
    def self.filter_based_on_date_range(start_date, end_date, state)
      with_state(state).updated_in_date_range(start_date, end_date)
    end

    # Public - Finds all of the PRs that have the current state, then filters to PRs that were updated within the
    # start_date and end_date. Lastly, it orders all of them based on the given order.
    # 
    # start_date - the start of the date range
    # end_date - the end of the data range
    # state - the current state (open, closed, or all) of the PRs
    # order - the order (descending or ascending) that the PRs should be ordered in
    #
    # Returns - the PRs that are within the date range and that are the state ordered 
    def self.state_based_order(start_date, end_date, state, order)
      order = ["ASC","DESC"].detect{|order_type| order_type.to_s == order.to_s.upcase } || "DESC"
      if state == "closed"
        with_state(state).updated_in_date_range(start_date, end_date).order("hubstats_pull_requests.closed_at #{order}")
      else #state == "open"
        with_state(state).updated_in_date_range(start_date, end_date).order("hubstats_pull_requests.created_at #{order}")
      end
    end

    # Public - Groups the PRs by either username or repo name, based on the string passed in.
    #
    # group - string that is the designated grouping
    #
    # Returns - the data grouped
    def self.group_by(group)
      if group == 'user'
        with_user_name.order("user_name ASC")
      elsif group == 'repo'
        with_repo_name.order("repo_name asc")
      else
        scoped
      end
    end
  end
end
