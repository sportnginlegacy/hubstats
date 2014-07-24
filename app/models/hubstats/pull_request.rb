module Hubstats
  class PullRequest < ActiveRecord::Base

    scope :closed_since, lambda {|time| where("closed_at > ?", time) }
    scope :updated_since, lambda {|time| where("updated_at > ?", time) }
    scope :opened_since, lambda {|time| where("created_at > ?", time) }
    scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}
    scope :belonging_to_repos, lambda {|repo_id| where(repo_id: repo_id.split(',')) if repo_id}
    scope :belonging_to_users, lambda {|user_id| where(user_id: user_id.split(',')) if user_id}
    scope :with_state, lambda {|state| (where(state: state) unless state == 'all') if state}
    scope :with_label, lambda { |label_name| ({ :joins => :labels, :conditions => {:hubstats_labels => {name: label_name.split(',')} } }) if label_name }
    scope :distinct, select("DISTINCT hubstats_pull_requests.*")

    attr_accessible :id, :url, :html_url, :diff_url, :patch_url, :issue_url, :commits_url,
      :review_comments_url, :review_comment_url, :comments_url, :statuses_url, :number,
      :state, :title, :body, :created_at, :updated_at, :closed_at, :merged_at, 
      :merge_commit_sha, :merged, :mergeable, :comments, :commits, :additions,
      :deletions, :changed_files, :user_id, :repo_id

    belongs_to :user
    belongs_to :repo
    has_and_belongs_to_many :labels, :join_table => 'hubstats_labels_pull_requests'

    def self.create_or_update(github_pull)
      github_pull = github_pull.to_h.with_indifferent_access if github_pull.respond_to? :to_h

      user = Hubstats::User.create_or_update(github_pull[:user])
      github_pull[:user_id] = user.id

      github_pull[:repository][:updated_at] = github_pull[:updated_at]
      repo = Hubstats::Repo.create_or_update(github_pull[:repository])
      github_pull[:repo_id] = repo.id

      pull_data = github_pull.slice(*column_names.map(&:to_sym))

      pull = where(:id => pull_data[:id]).first_or_create(pull_data)
      return pull if pull.update_attributes(pull_data)
      Rails.logger.warn pull.errors.inspect
    end

    def add_labels(labels)
      labels.map!{ |label| Hubstats::Label.first_or_create(label) }
      self.labels = labels
    end

    def self.state_based_order(timespan,state,order)
      order = ["ASC","DESC"].detect{|order_type| order_type.to_s == order.to_s.upcase } || "DESC"

      if state == "closed"
        closed_since(timespan).order("closed_at #{order}")
      else
        opened_since(timespan).order("created_at #{order}")
      end
    end

  end
end
