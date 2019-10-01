module Hubstats
  class Label < ApplicationRecord

    def self.record_timestamps; false; end

    # Various checks that can be used to filter and find info about labels.
    scope :with_ids, lambda {|pull_ids| (where("hubstats_labels_pull_requests.pull_request_id" => pull_ids))}
    scope :with_state, lambda {|state| (where(state: state) unless state == 'all') if state}

    # Public - Counts all of the labels that are assigned to one of the PRs that is passed in. This is then
    # merged with the list of PRs. It also shows a count of the number of PRs with each specific label.
    #
    # pull_requests - the PRs that are shown on the given index page
    #
    # Returns - the labels data
    def self.count_by_pull_requests(pull_requests)
      select("hubstats_labels.*")
       .select("COUNT(hubstats_labels_pull_requests.pull_request_id) AS pull_request_count")
       .joins(:pull_requests).merge(pull_requests)
       .having("pull_request_count > 0")
       .group("hubstats_labels.id")
       .order("pull_request_count DESC")
    end

    has_and_belongs_to_many :pull_requests, :join_table => 'hubstats_labels_pull_requests'

    # Public - Checks if the label is currently existing, and if it isn't, then makes a new label with
    # the specifications that are passed in.
    #
    # label - the info that's passed in about the new label
    #
    # Returns - the label
    def self.first_or_create(label)
      if exists = Hubstats::Label.where(name: label[:name]).first
        return exists
      else
        Label.new(name: label[:name], url: label[:url], color: label[:color])
      end
    end

  end
end
