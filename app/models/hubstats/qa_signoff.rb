module Hubstats
  class QaSignoff < ApplicationRecord

    def self.record_timestamps; false; end

    # Various checks that can be used to filter, sort, and find info about QA Signoffs.
    scope :signed_within_date_range, lambda {|start_date, end_date| where("hubstats_qa_signoffs.signed_at BETWEEN ? AND ?", start_date, end_date)}
    scope :belonging_to_repo, lambda {|repo_id| where(repo_id: repo_id)}
    scope :belonging_to_user, lambda {|user_id| where(user_id: user_id)}
    scope :belonging_to_pull_request, lambda {|pr_id| where(pull_request_id: pr_id)}
    scope :belonging_to_repos, lambda {|repo_id| where(repo_id: repo_id.split(',')) if repo_id}
    scope :belonging_to_users, lambda {|user_id| where(user_id: user_id.split(',')) if user_id}
    scope :belonging_to_pull_requests, lambda {|pr_id| where(pull_request_id: pr_id.split(',')) if pr_id}
    scope :distincter, -> { select("DISTINCT hubstats_qa_signoffs.*") }
    scope :with_repo_name, -> { select('DISTINCT hubstats_repos.name as repo_name, hubstats_qa_signoffs.*').joins("LEFT JOIN hubstats_repos ON hubstats_repos.id = hubstats_qa_signoffs.repo_id") }
    scope :with_user_name, -> { select('DISTINCT hubstats_users.login as user_name, hubstats_qa_signoffs.*').joins("LEFT JOIN hubstats_users ON hubstats_users.id = hubstats_qa_signoffs.user_id") }
    scope :with_pull_request_name, -> { select('DISTINCT hubstats_pull_requests.title as pr_name, hubstats_qa_signoffs.*').joins("LEFT JOIN hubstats_pull_requests ON hubstats_pull_requests.id = hubstats_qa_signoffs.pull_request_id") }

    belongs_to :user, optional: true
    belongs_to :repo, optional: true
    belongs_to :pull_request, optional: true

    # Public - Makes a new QA Signoff with the data that is passed in.
    #
    # repo_id - the id of the repository
    # pr_id - the id of the pull request
    # user_id - the id of the user who added the label
    #
    # Returns - the QA Signoff
    def self.first_or_create(repo_id, pr_id, user_id)
      QaSignoff.create(user_id: user_id,
                       repo_id: repo_id,
                       pull_request_id: pr_id,
                       label_name: 'qa-approved',
                       signed_at: Time.now.getutc)
    end

    # Public - Deletes the QA Signoff of the PR that is passed in.
    #
    # repo_id - the id of the repository the PR belongs to
    # pr_id - the id of the PR the signoff was deleted from
    #
    # Returns - the deleted QA Signoff
    def self.remove_signoff(repo_id, pr_id)
      signoff = Hubstats::QaSignoff.where(repo_id: repo_id).where(pull_request_id: pr_id).first
      signoff.destroy if signoff
    end
  end
end
