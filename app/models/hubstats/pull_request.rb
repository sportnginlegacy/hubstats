module Hubstats
  class PullRequest < ActiveRecord::Base
    scope :closed_since, lambda {|start_time, end_time| where("hubstats_pull_requests.closed_at > ? AND hubstats_pull_requests.closed_at < ?", start_time, end_time)}
    scope :updated_since, lambda {|start_time, end_time| where("hubstats_pull_requests.updated_at > ? AND hubstats_pull_requests.updated_at < ?", start_time, end_time)}
    scope :opened_since, lambda {|start_time, end_time| where("hubstats_pull_requests.created_at > ? AND hubstats_pull_requests.created_at < ?", start_time, end_time)}
    scope :merged_since, lambda {|start_time, end_time| where("hubstats_pull_requests.merged").where("hubstats_pull_requests.merged_at > ? AND hubstats_pull_requests.merged_at < ?", start_time, end_time)}
    scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}
    scope :belonging_to_deploy, lambda {|deploy_id| where(deploy_id: deploy_id)}
    scope :belonging_to_repos, lambda {|repo_id| where(repo_id: repo_id.split(',')) if repo_id}
    scope :belonging_to_users, lambda {|user_id| where(user_id: user_id.split(',')) if user_id}
    scope :group, lambda {|group| group_by(:repo_id) if group }
    scope :with_state, lambda {|state| (where(state: state) unless state == 'all') if state}
    scope :with_label, lambda { |label_name| ({ :joins => :labels, :conditions => {:hubstats_labels => {name: label_name.split(',')} } }) if label_name }
    scope :distinct, select("DISTINCT hubstats_pull_requests.*")
    scope :with_repo_name, select('DISTINCT hubstats_repos.name as repo_name, hubstats_pull_requests.*').joins("LEFT JOIN hubstats_repos ON hubstats_repos.id = hubstats_pull_requests.repo_id")
    scope :with_user_name, select('DISTINCT hubstats_users.login as user_name, hubstats_pull_requests.*').joins("LEFT JOIN hubstats_users ON hubstats_users.id = hubstats_pull_requests.user_id")

    attr_accessible :id, :url, :html_url, :diff_url, :patch_url, :issue_url, :commits_url,
      :review_comments_url, :review_comment_url, :comments_url, :statuses_url, :number,
      :state, :title, :body, :created_at, :updated_at, :closed_at, :merged_at, 
      :merge_commit_sha, :merged, :mergeable, :comments, :commits, :additions,
      :deletions, :changed_files, :user_id, :repo_id, :merged_by

    belongs_to :user
    belongs_to :repo
    belongs_to :deploy
    has_and_belongs_to_many :labels, :join_table => "hubstats_labels_pull_requests"

    def self.create_or_update(github_pull)
      github_pull = github_pull.to_h.with_indifferent_access if github_pull.respond_to? :to_h

      user = Hubstats::User.create_or_update(github_pull[:user])
      github_pull[:user_id] = user.id

      github_pull[:repository][:updated_at] = github_pull[:updated_at]
      repo = Hubstats::Repo.create_or_update(github_pull[:repository])
      github_pull[:repo_id] = repo.id

      pull_data = github_pull.slice(*column_names.map(&:to_sym))

      pull = where(:id => pull_data[:id]).first_or_create(pull_data)

      # Updates the merged_by part of the pull request and the user_id of the deploy
      if github_pull[:merged_by] && github_pull[:merged_by][:id]
        pull_data[:merged_by] = github_pull[:merged_by][:id]
        deploy = Hubstats::Deploy.where(id: pull.deploy_id, user_id: nil).first
          if deploy
            deploy.user_id = pull_data[:merged_by]
            deploy.save!
          end
      end

      return pull if pull.update_attributes(pull_data)
      Rails.logger.warn pull.errors.inspect
    end

    def add_labels(labels)
      labels.map!{ |label| Hubstats::Label.first_or_create(label) }
      self.labels = labels
    end

    def self.all_filtered(params, start_time, end_time)
      filter_based_on_date_range(start_time, end_time, params[:state])
       .belonging_to_users(params[:users])
       .belonging_to_repos(params[:repos])
    end

    def self.filter_based_on_date_range(start_time, end_time, state)
      with_state(state).updated_since(start_time, end_time)
    end

    def self.state_based_order(start_time, end_time , state, order)
      order = ["ASC","DESC"].detect{|order_type| order_type.to_s == order.to_s.upcase } || "DESC"
      if state == "closed"
        with_state(state).updated_since(start_time, end_time).order("hubstats_pull_requests.closed_at #{order}")
      else #state == "open"
        with_state(state).updated_since(start_time, end_time).order("hubstats_pull_requests.created_at #{order}")
      end
    end

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
